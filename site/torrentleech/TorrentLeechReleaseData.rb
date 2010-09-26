require 'cgi'
require 'sequel'

require 'nil/string'

require_relative 'shared/timeString'
require_relative 'shared/ReleaseData'

require_relative 'site/torrentleech/extractName'

class TorrentLeechReleaseData < ReleaseData
	Debugging = false
	
	Targets =
	[
		['Release', /<h1>(.+?)<\/h1>/, :name],
		['Path', /"(download\.php.+?)"/, :path],
		['Info hash', /<td valign="top" align=left>(.+?)<\/td>/, :infoHash],
		['Category', /Type<\/td><td valign="top" align=left>(.+?)<\/td>/, :category],
		['Size', /Size<\/td><td valign="top" align=left>.+?\((.+?) bytes\)/, :sizeString],
		['Release date', /Added<\/td><td valign="top" align=left>(.+?)<\/td>/, :releaseDate],
		['Snatched', /Snatched<\/td><td valign="top" align=left>(\d+) time\(s\)<\/td>/, :downloads],
		['Uploader', /Upped by<\/td><td valign="top" align=left>.+?>([^><]+)<.+?>/, :uploader],
		['File count', /\[See full list\]<\/a><\/td><td valign="top" align=left>(\d+) files<\/td>/, :fileCount, false],
		['Seeders', /<td valign="top" align=left>(\d+) seeder\(s\), /, :seeders],
		['Leechers', /, (\d+) leecher\(s\) = /, :leechers],
		['ID', /download\.php\/(\d+)\//, :id],
	]
	
	def processInput(pages)
		detailsPage = pages[0]
		nfoPage = pages[1]
		super(detailsPage)
		processNFO(nfoPage)
	end
	
	def postProcessing(input)
		size = @sizeString.gsub(',', '')
		if !size.isNumber
			errorMessage = "Invalid file size specified: #{@sizeString}"
			raise Error.new(errorMessage)
		end
		@size = size.to_i
		
		@id = @id.to_i
		@hits = @hits.to_i
		@downloads = @downloads.to_i
		@seeders = @seeders.to_i
		@leechers = @leechers.to_i
		
		@path = "/#{@path}" if !@path.empty? && @path[0] != '/'
		
		#the original @name is actually being ignored - this site is too much of a mess
		@name = extractNameFromTorrent(@path)
		
		if @fileCount == nil
			@fileCount = 1
		else
			@fileCount = @fileCount.to_i
		end
	end
	
	def processNFO(input)
		match = /<pre>.+?>([\s\S]+?)<\//.match(input)
		raise Error.new('Failed to get a match on the NFO data') if match == nil
		
		@nfo = CGI::unescapeHTML(match[1])
		@nfo.force_encoding 'CP437'
		@nfo = @nfo.encode 'UTF-8'
	end
	
	def getData
		return {
			site_id: @id,
			torrent_path: @path,
			info_hash: @infoHash,
			section_name: @category,
			name: @name,
			nfo: @nfo.to_sequel_blob,
			release_date: @releaseDate,
			release_size: @size,
			file_count: @fileCount,
			#screw it
			comment_count: nil,
			download_count: @downloads,
			seeder_count: @seeders,
			leecher_count: @leechers,
			uploader: @uploader,
		}
	end
end
