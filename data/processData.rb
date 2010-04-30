require 'nil/file'

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
