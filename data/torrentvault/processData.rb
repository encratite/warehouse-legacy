$:.concat ['../../shared']

require 'nil/file'

require 'preTime'
require 'sizeString'
require 'database'
require 'Configuration'

class TVReleaseData
	attr_reader :id
	
	Symbols =
	[
		:section,
		:path,
		:id,
		:name,
		:preTimeString,
		:addedString,
		:fileCount,
		:sizeString,
		:downloads,
		:seeders,
		:leechers,
		:uploader
	]
	
	def initialize(array)
		if array.size != Symbols.size
			puts array.inspect
			puts "Size mismatch: #{array} (#{Symbols.size} symbols vs. #{array.size} matches)"
			exit
		end
		offset = 0
		while offset < array.size
			symbol = ('@' + Symbols[offset].to_s).to_sym
			value = array[offset]
			instance_variable_set(symbol, value)
			offset += 1
			#puts "#{symbol}: #{value}"
		end
		
		@id = @id.to_i
		@preTime = parsePreTimeString(@preTimeString)
		@added = parsePreTimeString(@addedString)
		@fileCount = @fileCount.to_i
		@size = convertSizeString(@sizeString.gsub(',', ''))
		@downloads = @downloads.to_i
		@seeders = @seeders.to_i
		@leechers = @leechers.to_i
		
		match = />(.+)$/.match(@uploader)
		if match == nil
			@uploader = nil
		else
			@uploader = match[1]
			#puts "Uploader: #{@uploader}"
		end
	end
	
	def getData
		return {
			site_id: @id,
			torrent_path: @path,
			section_name: @section,
			name: @name,
			pre_time: @preTime,
			genre: nil,
			release_date: nil,
			
			release_date_offset: @added,
			release_size: @size,
			download_count: @downloads,
			seeder_count: @seeders,
			leecher_count: @leechers,
			uploader: @uploader
		}
	end
end

def processData(configuration)
	pattern = /switch_row_. torrent.+?title="(.+?)".+?"(torrents\.php\?.+?)".+?<strong>.+?torrents\.php\?id=(\d+).+?title="(.+?)".+?Pre: (.+?)<.+?<td class="nobr">(.+?)<.+?<td class="center">(\d+)<.+?<td class="nobr">(.+?)<.+?<td class="center">(\d+)<.+?<td class="center">(\d+)<.+?<td class="center">(\d+)<.+?<td class="center">(.+?)</
	
	database = getDatabase
	dataset = database[:torrentvault_data]

	counter = 1
	while true
		path = "output/#{counter}"
		puts "Processing #{path}"
		
		data = Nil.readFile(path)
		return if data == nil
		data = data.gsub("\n", '')
		#puts 'Scanning...'
		results = data.scan(pattern)
		#puts 'Done scanning'
		if results.empty?
			puts "No hits in #{path}"
			exit
		end
		results.each do |match|
			array = match.to_a
			release = TVReleaseData.new(array)
			dataset.where(site_id: release.id).delete
			dataset.insert(release.getData)
		end
		counter += 1
	end

end

#TVReleaseData.new('output/13')
#exit

processData Configuration
