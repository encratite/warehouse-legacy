require 'sequel'
require 'pg'
require 'set'

require 'nil/file'

require 'shared/ReleaseData'
require 'shared/Bencode'
require 'shared/QueueHandler'
require 'shared/OwnershipHandler'

require 'notification/NotificationReleaseData'

class ReleaseHandler
  def initialize(site, connections, configuration)
    @site = site

    @httpHandler = site.httpHandler
    @outputHandler = site.outputHandler
    #regular ReleaseSites don't have this member
    @downloadDelay = site.instance_variable_get(:@downloadDelay) || 0

    @database = connections.sqlDatabase
    @notification = connections.notificationClient

    @torrentPath = site.torrentPath
    @sizeLimit = site.releaseSizeLimit

    @releaseTableSymbol = site.table
    @releaseDataClass = site.releaseDataClass

    @queue = QueueHandler.new(@database)

    @ownership = OwnershipHandler.new(configuration)
  end

  def databaseDown(exception)
    output "The DBMS appears to be down: #{exception.message}"
    exit
  end

  def getMatchingUsersForFilterType(releaseData, type)
    release = releaseData.name

    select = 'select user_data.id as id, user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.release_filter_type as release_filter_type from user_release_filter, user_data'
    regexp = '? ~* user_release_filter.filter'

    typeString = type.to_s

    regexpCondition = '? ~* user_release_filter.filter'
    filterCondition = "user_release_filter.release_filter_type = ?"
    idCondition = 'user_data.id = user_release_filter.user_id'

    symbolString = "@#{type.to_s}"
    symbol = symbolString.to_sym

    if !releaseData.instance_variables.include?(symbol)
      #genres are not supported by all sites
      return false if type == :genre
      puts releaseData.inspect
      raise "Failed to retrieve instance variable of release #{releaseData.name} (symbol: #{symbol.to_s})"
    end
    target = releaseData.instance_variable_get(symbol)
    results = @database["#{select} where #{regexpCondition} and #{filterCondition} and #{idCondition}", target, typeString]
    puts "Debug: #{results.sql}"
    matchCount = results.count
    if matchCount > 0
      output "Matches for release #{release}: #{matchCount}"
      filterDictionary = {}
      results.each do |row|
        name = row[:user_name]
        filter = row[:filter]
        filterDictionary[name] = [] if filterDictionary[name] == nil
        filterDictionary[name] << "#{filter} (#{typeString})"
      end
      filterDictionary.each do |name, filters|
        output "#{name}: #{filters.inspect}"
      end
    end
    #need the user name, too, to change the ownership
    users = results.map{|x| [x[:id], x[:user_name]]}
    return users
  end

  def getMatchingFilterUsers(releaseData)
    types =
      [
       :name,
       :nfo,
       :genre
      ]

    userSet = Set.new

    types.each do |type|
      newUsers = getMatchingUsersForFilterType(releaseData, type)
      newUsers.each do |user|
        userSet << user
      end
    end

    return userSet.to_a
  end

  def insertData(releaseData)
    sql = nil
    begin
      insertData = releaseData.getData
      dataset = @database[@releaseTableSymbol]
      result = dataset.where(site_id: insertData[:site_id])
      sql = result.sql
      if result.count > 0
        puts 'This entry already exists - overwriting it'
        dataset.delete
      end
      dataset.insert(insertData)
    rescue	Sequel::DatabaseError => exception
      output "DBMS exception: #{exception.message}, SQL: #{sql}"
    end
  end

  def output(line)
    @outputHandler.output(line)
  end

  def processReleaseURL(release, url)
    tokens = url.split('://')
    if tokens.size != 2
      output "Invalid URL: #{url}"
      return
    end

    #unused as of now, ignore https
    protocol = tokens[0]
    identifier = tokens[1]

    offset = identifier.index('/')
    path = identifier[offset..-1]
    processReleasePath(release, path)
  end

  def processReleasePath(release, path)
    processReleasePaths(release, [path])
  end

  def processReleasePaths(release, paths)
    pages = []
    paths.each do |path|
      result = @httpHandler.get(path)
      if result == nil
        output "Error: Failed to retrieve path #{path} for release #{release}"
        return
      end
      pages << result
      sleep @downloadDelay
    end
    processReleaseData(release, pages)
  end

  def processReleaseData(release, pages)
    begin
      #reduce the array to its first element if possible, for the sake of not breaking the old release data classes
      if pages.size == 1
        input = pages[0]
      else
        input = pages
      end
      releaseData = @releaseDataClass.new(input)
      isOfInterest = false
      matchingUsers = nil
      @database.transaction do
        insertData(releaseData)
        matchingUsers = getMatchingFilterUsers(releaseData)
        isOfInterest = !matchingUsers.empty?
      end
      if isOfInterest
        output "Discovered a release of interest: #{release}"
        if releaseData.size > @sizeLimit
          output "Unluckily the size of this release exceeds the limit (#{releaseData.size} > #{@sizeLimit})"
          return
        end
        path = releaseData.path
        output "Downloading #{path}"
        torrentData = @httpHandler.get(path)
        if torrentData == nil
          output "HTTP error: Unable to retrieve path #{path}"
          return
        end
        torrent = Bencode.getTorrentName(torrentData)
        torrentPath = Nil.joinPaths(@torrentPath, torrent)
        if Nil.readFile(torrentPath) != nil
          output "Collision detected - aborting, #{torrentPath} already exists!"
          return
        end

        Nil.writeFile(torrentPath, torrentData)
        output "Downloaded #{path} to #{torrentPath}"

        if matchingUsers.size == 1
          #release was queued for one user only so we can change the filesystem ownership to reflect this
          #this will permit the user to cancel the download and the association with the user is clear in ls -l
          id, name = matchingUsers.first
          @ownership.changeOwnership(name, torrentPath)
        end

        releaseData = NotificationReleaseData.new(@site.name, releaseData.id, releaseData.name, releaseData.size, false)
        userIds = matchingUsers.map{|id, name| id}
        @queue.insertQueueEntry(releaseData, torrent, userIds)
        matchingUsers.each do |id, name|
          puts "Notifying user #{name} (ID: #{id}) about release #{releaseData.name}"
          @notification.queuedNotification(id, releaseData)
        end
      else
        output "#{release} is not a release of interest"
      end
    rescue Sequel::DatabaseConnectionError => exception
      databaseDown exception
    rescue ReleaseData::Error => exception
      output "Error: Unable to parse data of release #{release}: #{exception.message}"
    rescue Bencode::Error => exception
      output "A Bencode error occured: #{exception.message}"
    end
  end
end
