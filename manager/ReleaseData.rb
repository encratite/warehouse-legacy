require 'nil/string'

require 'preTime'

class ReleaseData
	class Error < StandardError
	end
	
	attr_reader :path, :size
	
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
		['Torrent path', /Download \(SSH\).+?href=\"(.+?)\"/, :path]
	]
	
	Debugging = false
	
	def initialize(input)
		processInput(input)
	end
	
	def processInput(input)
		Targets.each do |name, pattern, symbol|
			match = pattern.match(input)
			if match == nil
				errorMessage = "#{name} match failed"
				raise Error.new(errorMessage)
			end
			data = match[1]
			puts "#{name}: \"#{data}\" (#{match.size} match(es))" if Debugging
			symbol = ('@' + symbol.to_s).to_sym
			instance_variable_set(symbol, data)
		end
		
		@preTime = parsePreTimeString @preTimeString
		
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
		
		if Debugging
			puts "Size: #{@size}"
			puts "Pre-time in seconds: #{@preTime.inspect}"
		end
	end
	
	def getData
		return {
			site_id: @id,
			torrent_path: @path,
			section_name: @section,
			name: @release,
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
