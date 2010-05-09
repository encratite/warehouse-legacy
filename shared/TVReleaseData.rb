require 'shared/ReleaseData'
require 'shared/sizeString'
require 'shared/preTime'

require 'cgi'

class TVReleaseData < ReleaseData
	Targets =
	[
		['ID', /groupid=(\d+)"/, :id],
		['Release', /<title>(.+?) - TorrentVault/, :name],
		['Section', /<li>Category: (.+?)<\/li>/, :sectionName],
		['Uploader', /<li>Uploader: .+?>.+?>(.+?)<\/a>/, :uploader],
		#annoying format
		['Pre time', /<li>Pre: (.+?)<\//, :preTimeString],
		['Snatched', /<li>Snatched: (\d+)<\//, :downloads],
		['Seeders', /<li>Seeders: (\d+)<\//, :seeders],
		['Leechers', /<li>Leechers: (\d+)<\//, :leechers],
		#possibly incompatible, not sure
		['Release date', /First Added: .+?>(.+?)<\//, :releaseDate],
		#annoying format
		['Size', /<td class="nobr">(.+?)<\/td>/, :sizeString],
		['Torrent path', /"(torrents\.php\?action=download.+?)"/, :path],
	]
	
	def postProcessing(input)
		genreMatch = /<li>Genre: .+?>(.+?)<\//.match(input)
		if genreMatch == nil
			@genre = nil
		else
			@genre = genreMatch[1]
		end
		
		@id = @id.to_i
		
		@preTime = parsePreTimeString(@preTimeString)
		
		@downloads = @downloads.to_i
		@seeders = @seeders.to_i
		@leechers = @leechers.to_i
		
		begin
			@size = convertSizeString @sizeString
		rescue RuntimeError => error
			raise ReleaseData::Error.new(error.message)
		end
		
		@path = '/' + CGI::unescapeHTML(@path)
	end
	
	def debugging
		false
	end
	
	def getTargets
		Targets
	end
	
	def getData
		return {
			site_id: @id,
			section_name: @sectionName,
			torrent_path: @path,
			name: @name,
			pre_time: @preTime,
			genre: @genre,
			release_date: @releaseDate,
			release_size: @size,
			download_count: @downloads,
			seeder_count: @seeders,
			leecher_count: @leechers,
			uploader: @uploader
		}
	end
end
