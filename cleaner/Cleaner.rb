require 'fileutils'
require 'sequel'

require 'nil/string'
require 'nil/file'
require 'nil/time'
require 'nil/ipc'

require 'user-api/UserAPI'
require 'user-api/TorrentData'

require 'shared/OutputHandler'
require 'shared/QueueHandler'

class Cleaner
  Debugging = false
  TorrentExtension = '.torrent'

  def initialize(configuration, connections)
    torrentData = configuration::Torrent

    pathData = torrentData::Path
    @torrentPath = pathData::Torrent
    @downloadPath = pathData::Download
    @downloadDonePath = pathData::DownloadDone

    cleanerData = torrentData::Cleaner
    @freeSpaceMinimum = cleanerData::FreeSpaceMinimum
    @checkDelay = cleanerData::CheckDelay
    @unseededTorrentRemovalDelay = cleanerData::UnseededTorrentRemovalDelay
    @queueEntryAgeMaximum = cleanerData::QueueEntryAgeMaximum

    logPath = Nil.joinPaths(configuration::Logging::Path, cleanerData::Log)
    @output = OutputHandler.new(logPath)

    @userPath = pathData::User
    @filteredPath = pathData::Filtered

    @api = UserAPI.new(configuration, connections)

    @database = connections.sqlDatabase
    @queue = QueueHandler.new(@database)

    @notification = connections.notificationClient
  end

  def run
    while true
      begin
        removeDeadSymlinks
        processTorrents
        removeOldQueueEntries(@queueEntryAgeMaximum)
        while true
          break if !freeSomeSpace || Debugging
        end
        sleep @checkDelay
      rescue Nil::IPCError => exception
        output "An IPC error occured: #{exception.message}"
      end
    end
  end

  def removeOldQueueEntries(ageMaximum)
    limit = "(now() - '#{ageMaximum} seconds'::interval)".lit
    @database[:download_queue].filter{|x| x.queue_time <= limit}.delete
  end

  def getSortedFiles(path)
    input = Nil.readDirectory path
    if input == nil
      output "Unable to read path #{path} to retrieve a list of files"
      exit
    end
    return input.sort do |x, y|
      x.timeCreated <=> y.timeCreated
    end
  end

  def output(line)
    @output.output(line)
  end

  def getDownloads
    return getSortedFiles @downloadPath
  end

  def getCompletedDownloads
    return getSortedFiles @downloadDonePath
  end

  def getTorrents
    return getSortedFiles @torrentPath
  end

  def recursivelyRemoveDeadSymlinks(directory)
    data = Nil.readDirectory(directory, true)
    if data == nil
      output "Unable to process directory #{directory}"
      return
    end
    directories, files = data
    directories.each do |directory|
      recursivelyRemoveDeadSymlinks(directory.path)
    end
    files.each do |file|
      originalPath = Nil.joinPaths(@downloadDonePath, file.name)
      if !File.exist?(originalPath)
        output "Discovered a dead symlink: #{file.path}"
        deleteFile(file.path)
      end
    end
  end

  def removeDeadSymlinks
    users = Nil.readDirectory(@userPath)
    users.each do |user|
      filteredPath = Nil.joinPaths(user.path, @filteredPath)
      recursivelyRemoveDeadSymlinks(filteredPath)
    end
  end

  def deleteDirectory(path)
    output "Deleting directory #{path}"
    FileUtils.remove_dir(path, true) if !Debugging
    release = File.basename(path)
    #removing the symlinks at this point is no longer necessary because of the general removeDeadSymlinks
    return
  end

  def notifyUsersAboutDeletionOfTorrent(release, message, isError)
    users = @queue.getQueueEntryUsers(release)
    if users == nil
      output "Unable to retrieve users for release #{release}"
      return false
    end

    users.each do |user|
      output "Notifying user #{user.name} about the deletion of release #{release}: #{message}"
      if isError
        @notification.downloadErrorNotification(user.name, release, message)
      else
        @notification.downloadDeletedNotification(user.name, release, message)
      end
    end
    return true
  end

  def deleteTorrent(path, message, isError = false)
    release = getReleaseNameFromPath(path)
    notifyUsersAboutDeletionOfTorrent(release, message, isError)
    @queue.removeQueueEntry(File.basename(path))
    deleteFile(path)
  end

  def deleteFile(path)
    output "Deleting file #{path}"
    FileUtils.rm_f path if !Debugging
  end

  def processTorrents
    begin
      torrents = @api.getTorrents
      torrents = removeGhostTorrents(torrents)
      checkForUnseededTorrents(torrents)
    rescue RuntimeError => exception
      output "Torrent processing error: #{exception.message}"
    end
  end

  def removeGhostTorrents(torrents)
    outputTorrents = []
    torrents.each do |torrent|
      if torrent.torrentPath.empty?
        output "Discovered an entry in rtorrent which doesn't have a torrent file associated with it: #{torrent.name}"
        @api.removeTorrentEntry(torrent.infoHash)
        downloadPath = Nil.joinPaths(@downloadPath, torrent.name)
        deleteDirectory(downloadPath)
      else
        outputTorrents << torrent
      end
    end
    return outputTorrents
  end

  def checkForUnseededTorrents(torrents)
    unseededTorrents = torrents.reject do |torrent|
      target = torrent.bytesDone
      if target.class != Fixnum
        puts "Invalid class: #{target.class}"
        puts torrent.inspect
        exit
      end
      torrent.bytesDone > 0
    end
    unseededTorrents.each do |torrent|
      torrentPath = Nil.joinPaths(@torrentPath, File.basename(torrent.torrentPath))
      info = Nil.getFileInformation(torrentPath)
      if info == nil
        output "Failed to retrieve age of torrent #{torrentPath}"
        next
      end
      timeTorrentWentUnseeded = Time.now - info.timeCreated
      if timeTorrentWentUnseeded > @unseededTorrentRemovalDelay
        name = torrent.name
        downloadPath = Nil.joinPaths(@downloadPath, name)
        output "Getting rid of unseeded torrent #{name}"
        deleteTorrent(torrentPath, "Removed unseeded release #{name}", true)
        deleteDirectory(downloadPath)
      end
    end
  end

  def orphanCheck
    torrentBases = @torrents.map do |torrent|
      torrent.name.gsub(/\.torrent$/, '')
    end
    @downloads.each do |entry|
      if !torrentBases.include?(entry.name)
        output "Encountered an incomplete download without a torrent (#{entry.name}), removing it"
        deleteDirectory entry.path
      end
    end
    @completedDownloads.each do |entry|
      if !torrentBases.include?(entry.name)
        output "Encountered a completed download without a torrent (#{entry.name}), removing it"
        deleteDirectory entry.path
      end
    end
    return nil
  end

  def getReleaseNameFromPath(path)
    torrent = File.basename(path)
    release = torrent[0..(torrent.size - TorrentExtension.size - 1)]
    return release
  end

  def getFreeSpace
    return 0 if Debugging
    return Nil.getFreeSpace @downloadPath
  end

  def freeSpaceInDirectory(entries, directory)
    output "Attempting to free space in directory #{directory}"
    if entries.empty?
      output 'This directory is empty'
      return false
    end
    target = entries[0]
    deleteDirectory target.path
    name = target.name
    torrentFile = File.expand_path(name + TorrentExtension, @torrentPath)
    deleteTorrent(torrentFile, "Removed release #{name} because there was not enough space left on the disk")
    return true
  end

  def freeCompletedDownloadSpace
    return freeSpaceInDirectory(@completedDownloads, @downloadDonePath)
  end

  def freeDownloadSpace
    return freeSpaceInDirectory(@downloads, @downloadPath)
  end

  def freeSomeSpace
    freeSpace = getFreeSpace
    freeSpaceString = Nil.getSizeString freeSpace
    freeSpaceMinimumString = Nil.getSizeString @freeSpaceMinimum
    infoString = "#{Nil.timestamp} Free space: #{freeSpaceString}, required minimum: #{freeSpaceMinimumString}"
    if freeSpace > @freeSpaceMinimum
      output "#{infoString} - no action required"
      return false
    end
    output "#{infoString} - need to remove files"
    @downloads = getDownloads
    @completedDownloads = getCompletedDownloads
    @torrents = getTorrents
    orphanCheck
    return true if getFreeSpace > @freeSpaceMinimum
    return true if freeCompletedDownloadSpace
    freeDownloadSpace
    return true
  end
end
