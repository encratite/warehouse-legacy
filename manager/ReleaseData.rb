require 'nil/string'

class ReleaseData
	Targets =
	[
		['Release', /<h1>(.+?)<\/h1>/, :release],
		['ID', /\?id=(\d+)\"/, :id],
		['Info hash', /<td valign=\"top\" align=left>(.+?)<\/td>/, :infoHash],
		['Pre-time', />Pre Time<\/td>.+?>(.+?)<\/td>/, :preTimeString],
		['Size', />Size<\/td>.+?\((.+?) bytes/, :sizeString],
		['Date', />Added<\/td>.+?>(.+?)</, :date],
		['Hits', />Hits<\/td>.+?>(\d+)</, :hits],
		['Downloads', />Snatched<\/td>.+?>(\d+) time\(s\)/, :downloads],
		['Seeders', />(\d+) seeder\(s\)/, :seeders],
		['Leechers', /, (\d+) leecher\(s\)/, :leechers],
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
				raise errorMessage
			end
			data = match[1]
			puts "#{name}: \"#{data}\" (#{match.size} matches)" if Debugging
			symbol = ('@' + symbol.to_s).to_sym
			instance_variable_set(symbol, data)
		end
		
		preTimePatterns =
		[
			[/(\d+) second/, 1],
			[/(\d+) minute/, 60],
			[/(\d+) hour/, 60]
		]
		
		factor = 1
		preTime = 0
		preTimePatterns.each do |pattern, currentFactor|
			factor *= currentFactor
			match = pattern.match(@preTimeString)
			break if match == nil
			data = match[1]
			preTime += data.to_i * factor
		end
		
		if preTime == 0
			@preTime = nil
		else
			@preTime = preTime
		end
		
		size = @sizeString.gsub(',', '')
		raise "Invalid file size specified: #{@sizeString}" if !size.isNumber
		@size = size.to_i
		
		@hits = @hits.to_i
		@downloads = @downloads.to_i
		@seeders = @seeders.to_i
		@leechers = @leechers.to_i		
		
		if Debugging
			puts "Size: #{@size}"
			puts "Pre-time in seconds: #{@preTime.inspect}"
		end
	end
end
