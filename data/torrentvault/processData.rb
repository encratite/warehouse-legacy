require 'nil/file'

class TVReleaseData
	Symbols =
	[
		:section,
		:path,
		:name,
		:id,
		:preTimeString,
		:addedString,
		:fileCount,
		:sizeString,
		:downloads,
		:seeders,
		:leechers,
		:uploader
	]
	
	Pattern = /switch_row_3 torrent.+?title="(.+?)".+?"(torrents\.php\?.+?)".+?<strong>.?+torrents\.php\?id=(\d+).?+title="(.+?)".+?Pre: (.+?)<.+?<td class="nobr">(.+?)<.+?<td class="nobr">(\d+)<.+?<td class="center">(\d+)<.+?<td class="center">(\d+)<.+?<td class="center">(\d+)<.+?user.php.+?>(.+?)</
	
	def initialize(path)
		data = Nil.readFile(path)
		data = data.gsub("\n", '')
		results = data.scan(Pattern)
		if results.empty?
			raise "No hits in #{path}"
			exit
		end
		results.each do |match|
			array = match.to_a[1..-1]
			if array.size != Symbols.size
				puts "Size mismatch: #{array}"
				exit
			end
			offset = 0
			while offset < array.size
				symbol = ('@' + Symbols[offset].to_s).to_sym
				value = array[offset]
				instance_variable_set(symbol, value)
				offset += 1
				puts "#{symbol}: #{value}"
			end
		end
	end
end

TVReleaseData.new('output/1')
exit

entries = Nil.readDirectory 'output'

entries.each do |entry|
	data = TVReleaseData.new(entry.path)
end
