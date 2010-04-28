class ReleaseData
	Targets =
	[
		['Release', /<h1>(.+)<\/h1>/, :release],
		['ID', /\?id=(\d+)\"/, :id],
		['Info hash', /<td valign=\"top\" align=left>(.+)<\/td>/, :infoHash],
		['Pre-time', />Pre Time<\/td>.+>(.+)<\/td>/, :preTimeString],
		['Size', />Size<\/td>.+\((.+) bytes/, :sizeString],
		['Date', />Added<\/td>.+>(.+)</, :date],
		['Hits', />Hits<\/td>.+>(.+)</, :hits],
		['Downloads', />Snatched<br />.+>(\d+) time(s)/, :downloads],
		['Seeders', />(\d+) seeder\(s\)/, :seeders],
		['Leechers', /, (\d+) leecher\(s\)/, :leechers],
	]
	
	
	def initialize(input)
		processInput(input)
	end
	
	def processInput(input)
		Targets.each do |name, pattern, symbol|
			match = pattern.match(input)
			if match == nil
				errorMessage = "#{name} match failed"
				raise errorMessage
			end
			data = match[1]
			puts "#{name}: #{data}"
			symbol = ('@' + symbol.to_s).to_sym
			instance_variable_set(symbol, data)
		end
	end
end
