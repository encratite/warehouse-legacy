require 'nil/file'
require 'shared/preTime'
require 'configuration/Configuration'
require 'shared/database'

class SCCReleaseData
	attr_reader :name, :id
	
	Symbols =
	[
		:type,
		:section,
		:id,
		:name,
		:preTime,
		:files,
		:commentCount,
		:date,
		:time,
		:size,
		:unit,
		:hits,
		:seeders,
		:leechers
	]
	
	def initialize(array)
		offset = 0
		if array.size != Symbols.size
			puts "Size mismatch: #{array}"
			exit
		end
		while offset < array.size
			symbol = ('@' + Symbols[offset].to_s).to_sym
			value = array[offset]
			instance_variable_set(symbol, value)
			offset += 1
		end
		
		units =
		[
			'kB',
			'MB',
			'GB'
		]
		
		factor = 1024
		
		unitOffset = units.index @unit
		if unitOffset == nil
			puts "Unable to find unit: #{@unit}"
			exit
		end
		
		size = @size.to_f
		size *= factor**(unitOffset + 1)
		@size = size.to_i
		
		@preTime = parsePreTimeString @preTime
		
		@id = @id.to_i
		@files = @files.to_i
		@commentCount = @commentCOunt.to_i
		@date = "#{@date} #{@time}"
		@hits = @hits.to_i
		@seeders = @seeders.to_i
		@leechers = @leechers.to_i
		
		download =
			@type == 'archive' ?
			'downloadbig2' :
			'download2'
			
		@name = @name.gsub(' ', '_')
		
		@torrentPath = "/#{download}.php/#{@id}/40d5b69470486753f78986717cf55ce7/#{@name}.torrent"
		
		#puts @id
	end
	
	def getData
		return {
			site_id: @id,
			torrent_path: @torrentPath,
			section_name: @section,
			name: @name,
			info_hash: nil,
			pre_time: @preTime,
			file_count: @files,
			release_date: @date,
			release_size: @size,
			hit_count: @hits,
			download_count: @hits,
			seeder_count: @seeders,
			leecher_count: @leechers
		}
	end
end

class DataExtractor
	def initialize(database, pattern)
		@dataset = database[:scene_access_data]
		@pattern = pattern
	end

	def processFile(path)
		puts "Processing #{path}"
		data = Nil.readFile path
		return false if data == nil
		data = data.gsub("\n", '')
		results = data.scan(@pattern)
		if results.empty?
			puts "No hits in #{path}"
			return false
		end
		results.each do |array|
			#puts array.inspect
			#next
			release = SCCReleaseData.new array
			data = release.getData
			@dataset.filter(site_id: release.id).delete
			@dataset.insert(data)
		end
		if results.size != 15
			puts "Not enough results! #{results.size}"
		end
		return true
	end
end

def processDirectory(directory)
	#attern = /"\/(browse|browse2|archive)\.php\?cat=\d+".+?alt="(.+?)".+?\?id=(\d+)&.+?<b>(.+?)<\/b>.+?small>(.+?)<\/font>.+?filelist=1">(\d+)<.+?right">(\d+)<.+?<nobr>(.+?)<br \/>(.+?)<\/nobr>.+?center>(.+?)<br>(.+?)<.+?center>(\d+)<.+?#fffff'>(\d+)<.+?>(\d+)</

	pattern = /"\/(browse|browse2|archive)\.php\?cat=\d+".+?alt="(.+?)".+?\?id=(\d+)&.+?<b>(.+?)<\/b>.+?small>(.+?)<\/font>.+?">(\d+)<.+?">(\d+)<.+?<nobr>(.+?)<br \/>(.+?)<\/nobr>.+?center>(.+?)<br>(.+?)<.+?center>(\d+)<.+?#fffff'>(\d+)<.+?>(\d+)</

	database = getDatabase
	extractor = DataExtractor.new(database, pattern)

	#extractor.processFile("#{directory}/0")
	#exit

	#counter = 0
	counter = 0
	while true
		break if !extractor.processFile("#{directory}/#{counter}")
		counter += 1
	end
end

[
	#'browse',
	#'browse2',
	'archive'
].each do |directory|
	processDirectory directory
end
