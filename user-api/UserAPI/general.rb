require 'nil/file'
require 'nil/network'

require 'user-api/SiteStatistics'

require 'shared/torrent'

require 'notification/NotificationReleaseData'

class UserAPI
	def getSiteStatistics(site)
		table = @database[site.table]
		releaseCount = table.count
		totalSize = table.sum(:release_size).to_i
		#special case for an empty table
		totalSize = 0 if totalSize == nil
		output = SiteStatistics.new(releaseCount, totalSize)
		return output
	end
	
	def getFreeSpace
		return Nil.getFreeSpace(@torrentPath)
	end
	
	#this function can be used to calculate the current download/upload speed of the server
	#it also returns a timestamp in order to enable clients to eradicate timing jitter/inaccuracies due to packet delays
	def getBytesTransferred
		downloaded, uploaded = Nil.getDeviceBytes(@nic)
		
		output =
		{
			'downloaded' => downloaded,
			'uploaded' => uploaded,
			'timestamp' => Time.now.utc.to_f
		}
		
		return output
	end
	
	#WARNING: this function actually deals with base names within the filesystem and not the abstract release names from HTTP sources!
	#These names correspond to the entries within the bencoded data in the torrent files
	#Users may only delete releases that were queued manually by themselves
	
	#This function should not be exposed to the JSON RPC API until the username issue is fixed!
	
	def deleteTorrent(target)
		if isIllegalName(target)
			error 'You have specified an invalid release name.'
		end
		filename = Torrent.getTorrentName(target)
		torrent = Nil.joinPaths(@torrentPath, filename)
		begin
			stat = File.stat(torrent)
			user = Etc.getpwuid(stat.uid).name
			if user != @user.name
				error "#{filename} is owned by another user - ask the administrator for help."
			end
			FileUtils.rm(torrent)
			@database.transaction do
				#notify the user about the removal of the torrent
				releaseData = NotificationReleaseData.fromTable(target, @database)
				@notification.deletedNotification(@user.id, releaseData)
				#remove the corresponding entry from the queue
				@queue.removeQueueEntry(target)
			end
		rescue Errno::EACCES
			error "You do not have the permission to remove #{filename}."
		rescue Errno::ENOENT
			error "Unable to find #{filename}."
		end
	end
	
	def isAdministrator
		return @user.isAdministrator
	end
	
	def getReleaseSizeLimit
		return @releaseSizeLimit
	end
	
	def getSearchResultCountMaximum
		return @searchResultMaximum
	end
	
	def getSiteNames
		return @sites.map{|x| x.name}
	end
end
