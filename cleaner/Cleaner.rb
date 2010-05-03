require 'nil/string'
require 'nil/file'
require 'nil/time'

require 'fileutils'

class Cleaner
	Debugging = false
	
	def initialize(configuration)
		@torrentPath = configuration::Torrent::TorrentPath
		@downloadPath = configuration::Torrent::DownloadPath
		@downloadDonePath = configuration::Torrent::DownloadDonePath
		@freeSpaceMinimum = configuration::Torrent::Cleaner::FreeSpaceMinimum
		@checkDelay = configuration::Torrent::Cleaner::CheckDelay
	end
	
	def run
		while true
			while true
				break if !freeSomeSpace || Debugging
			end
			sleep @checkDelay
		end
	end
	
	def getSortedFiles(path)
		input = Nil.readDirectory path
		return input.sort do |x, y|
			x.timeCreated <=> y.timeCreated
		end
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
	
	def deleteDirectory(path)
		puts "Deleting directory #{path}"
		FileUtils.remove_dir(path, true) if !Debugging
		return nil
	end
	
	def deleteFile(path)
		puts "Deleting file #{path}"
		FileUtil.rm_f path if !Debugging
	end
	
	def orphanCheck
		torrentBases = @torrents.map do |torrent|
			torrent.name.gsub(/\.torrent$/, '')
		end
		@downloads.each do |entry|
			if !torrentBases.include?(entry.name)
				puts "Encountered an incomplete download without a torrent (#{entry.name}), removing it"
				deleteDirectory entry.path
			end
		end
		@completedDownloads.each do |entry|
			if !torrentBases.include?(entry.name)
				puts "Encountered a completed download without a torrent (#{entry.name}), removing it"
				deleteDirectory entry.path
			end
		end
		return nil
	end
	
	def getFreeSpace
		return 0 if Debugging
		return Nil.getFreeSpace @downloadPath
	end
	
	def freeSpaceInDirectory(entries, directory)
		puts "Attempting to free space in directory #{directory}"
		if entries.empty?
			puts 'This directory is empty'
			return false
		end
		target = entries[0]
		deleteDirectory target.path
		torrentFile = File.expand_path(target.name + '.torrent', @torrentPath)
		deleteFile torrentFile
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
			puts "#{infoString} - no action required"
			return false
		end
		puts "#{infoString} - need to remove files"
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
