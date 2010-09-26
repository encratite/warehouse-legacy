require 'nil/string'

require_relative 'shared/timeString'
require_relative 'shared/ReleaseData'

require 'cgi'

class SceneAccessReleaseData < ReleaseData
	Debugging = false
	
	Targets =
	[
		['Release', /<h1>(.+?)<\/h1>/, :name],
		['ID', /Download.+?\?id=(\d+)\"/, :id],
		['Info hash', /<td valign=\"top\" align=left>(.+?)<\/td>/, :infoHash],
		['Pre-time', />Pre Time<\/td>.+?>(.+?)<\/td>/, :preTimeString],
		['Section', />Type<\/td>.+>(.+)<\/td>/, :section],
		['Size', />Size<\/td>.+?\((.+?) bytes/, :sizeString],
		['Date', />Added<\/td>.+?>(.+?)</, :date],
		['Hits', />Hits<\/td>.+?>(\d+)</, :hits],
		['Downloads', />Snatched<\/td>.+?>(\d+) time\(s\)/, :downloads],
		['Files', />Num files<.+?>(\d+) file/, :files],
		['Seeders', />(\d+) seeder\(s\)/, :seeders],
		['Leechers', /, (\d+) leecher\(s\)/, :leechers],
		['Torrent path', /Download \(SSH\).+?href=\"(.+?)\"/, :path],
		['NFO', /<div id="ka3".+?\/>([\s\S]+?)<\/div>/, :nfo, false],
	]
	
	def removeHTMLLinks(input)
		output = input.gsub(/<a .+?>(.+?)<\/a>/) { |match| $1 }
		return output
	end
	
	def postProcessing(input)
		@preTime = parseTimeString @preTimeString
		
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
		
		if @nfo != nil
			@nfo = @nfo.gsub('<br>', '')
			@nfo = @nfo.gsub('&nbsp;', ' ')
			@nfo = CGI::unescapeHTML(@nfo)
			@nfo = removeHTMLLinks(@nfo)
		end
		
		if Debugging
			puts "Size: #{@size}"
			puts "Pre-time in seconds: #{@preTime.inspect}"
			puts "NFO: #{@nfo}"
		end
	end
	
	def getData
		return {
			site_id: @id,
			torrent_path: @path,
			section_name: @section,
			name: @name,
			nfo: @nfo,
			info_hash: @infoHash,
			pre_time: @preTime,
			file_count: @files,
			release_date: @date,
			release_size: @size,
			hit_count: @hits,
			download_count: @downloads,
			seeder_count: @seeders,
			leecher_count: @leechers
		}
	end
end
