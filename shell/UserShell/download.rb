require 'nil/file'

class UserShell
	#returns false if there was no hit, nil on hits with errors, true on hits with successful downloads
	def downloadTorrent(site, target)
		table = site.table.to_s
		select = "select name, site_id, release_size, torrent_path from #{table} where"
		if target.class == Fixnum
			result = @database["#{select} site_id = ?", target]
		else
			result = @database["#{select} name = ?", target]
		end
		if result.empty?
			#debug "Tried site #{site.name}, no hits. Target was #{target}. Table is #{table}."
			#debug "SQL: #{result.sql}"
			return false
		else
			#debug "Tried site #{site.name}, got a hit for #{target}."
		end
		result = result.first
		
		size = result[:release_size]
		if size > @releaseSizeLimit
			sizeString = Nil.getSizeString size
			sizeLimitString = Nil.getSizeString @releaseSizeLimit
			
			error "This release has a size of #{sizeString} which exceeds the current limit of #{sizeLimitString}"
			return
		end
		
		puts "Attempting to queue release #{result[:name]}"
		
		administrator = 'please contact the administrator'
		
		begin
			if site == 'SCC'
				detailsPath = "/details.php?id=#{result[:site_id]}"
				data = site.httpHandler.get(detailsPath)
				raise HTTPError.new 'Unable to retrieve details on this release' if data == nil
				
				releaseData = SceneAccessReleaseData.new data
				httpPath = releaseData.path
				
				torrentMatch = /\/([^\/]+\.torrent)/.match(httpPath)
				raise HTTPError.new 'Unable to extract the filename from the details' if torrentMatch == nil
				torrent = torrentMatch[1]
			else
				httpPath = result[:torrent_path]
				torrent = result[:name] + '.torrent'
			end
			
			if torrent.index('/') != nil
				error "Invalid torrent name - #{administrator}."
				return
			end
			
			torrentPath = File.expand_path(torrent, @torrentPath)
			
			if Nil.readFile(torrentPath) != nil
				warning 'This release had already been queued, overwriting it'
				#return
			end
			
			debug "Downloading path #{httpPath} from site #{site.name}"
			data = site.httpHandler.get(httpPath)
			if data == nil
				error "HTTP error: Unable to queue release - #{administrator}"
				return
			end
			
			Nil.writeFile(torrentPath, data)
			
			success 'Success!'
		rescue HTTPError => exception
			error "HTTP error: #{exception.message} - #{administrator}."
			return
		rescue ReleaseData::Error => exception
			error "An error occured parsing the details: #{exception.message} - #{administrator}."
			return
		rescue Errno::EACCES
			error 'Failed to overwrite file - access denied.'
			return
		end
		
		return true
	end
end
