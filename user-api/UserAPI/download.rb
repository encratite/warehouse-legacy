require 'net/http'

require 'etc'

require 'nil/file'
require 'nil/string'
require 'nil/environment'

require 'shared/Bencode'

class UserAPI
	def prepareTorrentDownload(site, target)
		table = site.table.to_s
		select = "select name, site_id, release_size, torrent_path from #{table} where"
		if target.class == Fixnum
			result = @database["#{select} site_id = ?", target]
		else
			result = @database["#{select} name = ?", target]
		end
		if result.empty?
			return nil
		end
		result = result.first
		
		size = result[:release_size]
		if size > @releaseSizeLimit
			sizeString = Nil.getSizeString size
			sizeLimitString = Nil.getSizeString @releaseSizeLimit
			
			error "This release has a size of #{sizeString} which exceeds the current limit of #{sizeLimitString}"
		end
		return result
	end
	
	def performTorrentDownload(site, data)
		administrator = 'please contact the administrator'
		
		begin
			if site == 'SCC'
				detailsPath = "/details.php?id=#{data[:site_id]}"
				data = site.httpHandler.get(detailsPath)
				raise 'Unable to retrieve details on this release' if data == nil
				
				releaseData = SceneAccessReleaseData.new data
				httpPath = releaseData.path
			else
				httpPath = data[:torrent_path]
			end
			
			data = site.httpHandler.get(httpPath)
			if data == nil
				error "HTTP error: Unable to queue release - #{administrator}"
			end
			
			torrent = Bencode.getTorrentName(data)
			torrentPath = File.expand_path(torrent, @torrentPath)
			
			begin
				Nil.writeFile(torrentPath, data)
			rescue Errno::EACCES
				error 'Failed to overwrite file - access denied.'
			end
			
			if @user.name != Nil.getUser
				commandLine = "#{@changeOwnershipPath} #{@user.name} #{torrentPath}"
				message = `#{commandLine}`
				returnCode = $?.to_i
				if returnCode != 0
					raise "Failed to transfer ownership of torrent #{torrentPath} to #{@user.name}: #{message}"
				end
			end
		rescue RuntimeError => exception
			error "Error: #{exception.message} - #{administrator}."
		rescue ReleaseData::Error => exception
			error "An error occured parsing the details: #{exception.message} - #{administrator}."
		end
	end

	#target may be a numeric ID (specifying the ID of the torrent on that particular site) or a string
	#returns false if the torrent could not be found, true on success - throws an exception when an error occurs
	def downloadTorrentFromSite(site, target)
		data = prepareTorrentDownload(site, target)
		return false if data == nil
		performTorrentDownload(site, data)
		return true
	end
	
	#returns true if there was a match for the release name on any of the sites - false otherwise
	def downloadTorrentByName(name)
		@sites.each do |site|
			result = downloadTorrentFromSite(site, name)
			case result
				when false then next
				when true then return true
			end
		end
		return false
	end
	
	def downloadTorrentById(site, id)
		return downloadTorrentFromSite(site, id)
	end
end
