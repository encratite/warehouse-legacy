require 'nil/file'
require 'nil/network'

require 'user-api/SiteStatistics'

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
	def getBytesTransferred
		return Nil.getDeviceBytes(@nic)
	end
	
	#this function should not be exposed to the JSON RPC API yet until the username issue is fixed
	def deleteTorrent(target)
		filename = target + '.torrent'
		if isIllegalName(filename)
			error 'You have specified an invalid release name.'
		end
		torrent = Nil.joinPaths(@torrentPath, filename)
		begin
			stat = File.stat(torrent)
			user = Etc.getpwuid(stat.uid).name
			if user != @user.name
				error "#{filename} is owned by another user - ask the administrator for help."
			end
			FileUtils.rm(torrent)
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
