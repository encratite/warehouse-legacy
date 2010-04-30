require 'nil/file'
require 'preTime'

class ReleaseData
	Symbols =
	[
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
			puts "Size mismatch"
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
			'KB',
			'MB',
			'GB'
		]
		
		factor = 1024
		
		unitOffset = units.index unit
		if unitOffset == nil
			puts "Unable to find unit: #{unit}"
			exit
		end
		
		size = @size.to_f
		size *= factor**(unitOffset + 1)
		@size = size.to_i
		
		@preTime = parsePreTimeString @preTime
		
		@id = @id.to_i
		@files = @files.to_i
		@commentCount = @commentCOunt.to_i
		@date = "#{date} #{time}"
		@hits = @hits.to_i
		@seeders = @seeders.to_i
		@leechers = @leechers.to_i
		
		@torrentPath = "/download2.php/#{@id}/40d5b69470486753f78986717cf55ce7/#{@name}.torrent"
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

def processFile(path)
	pattern = /"\/browse.php\?cat=\d+".+?alt="(.+?)".+?\?id=(\d+)&.+?<b>(.+?)<\/b>.+?small>(.+?)<\/font>.+?filelist=1">(\d+)<.+?right">(\d+)<.+?<nobr>(.+?)<br \/>(.+?)<\/nobr>.+?center>(.+?)<br>(.+?)<.+?center>(\d+)<.+?#fffff'>(\d+)<.+?todlers=1>(\d+)</
	
	
	data = Nil.readFile path
	return false if data == nil
	data = data.gsub("\n", '')
	match = pattern.match(data)
	if match == nil
		puts 'Fuck'
		exit
	else
		output = match.to_a[1..-1]
		puts output.inspect
	end
end

processFile('browse/0')
