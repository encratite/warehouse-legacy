require 'nil/file'

require 'shared/timeString'
require 'shared/sizeString'
require 'shared/sqlDatabase'
require 'configuration/Configuration'

class TorrentVaultReleaseData
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
	
	def initialize(array, fileTimestamp)
		@fileTimestamp = fileTimestamp
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
		@preTime = parseTimeString(@preTimeString)
		if @preTime == nil
			#puts "Failed to parse pre-time string: #{@preTimeString}"
			#exit
		end
		@added = parseTimeString(@addedString)
		if @added == nil
			puts "Failed to parse added time string: #{@addedString}"
			exit
		end
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
			release_date: "timestamp '#{@fileTimestamp.utc.to_s}' - interval '#{@added} seconds'".lit,
			release_date_offset: @added,
			release_size: @size,
			download_count: @downloads,
			seeder_count: @seeders,
			leecher_count: @leechers,
			uploader: @uploader
		}
	end
end

def processData(path, configuration)
	pattern = /switch_row_. torrent.+?title="(.+?)".+?"(torrents\.php\?.+?)".+?<strong>.+?torrents\.php\?id=(\d+).+?title="(.+?)".+?Pre: (.+?)<.+?<td class="nobr">(.+?)<.+?<td class="center">(\d+)<.+?<td class="nobr">(.+?)<.+?<td class="center">(\d+)<.+?<td class="center">(\d+)<.+?<td class="center">(\d+)<.+?<td class="center">(.+?)</
	
	database = getSQLDatabase
	dataset = database[:torrentvault_data]

	files = Nil.readDirectory(path)
	counter = 0
	files.each do |file|
		progress = Float(counter) / files.size * 100
		path = file.path
		data = Nil.readFile(path)
		printf("%s (%.2f%%)\n", file.name, progress)
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
			release = TorrentVaultReleaseData.new(array, file.timeModified)
			data = dataset.where(site_id: release.id).select(:release_date, :release_date_offset)
			if data.empty?
				dataset.insert(release.getData)
			else
				#The release is already in the database, check it it's broken
				data = data.first
				if data[:release_date] == nil
					#It is broken, get rid of it and replace it
					dataset.where(site_id: release.id).delete
					dataset.insert(release.getData)
				end
			end
		end
		counter += 1
	end

end

htmlPath = 'html/torrentvault'
processData(htmlPath, Configuration)
