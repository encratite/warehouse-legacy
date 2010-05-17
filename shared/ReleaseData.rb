class ReleaseData
	attr_reader :name, :path, :size, :nfo, :genre
	
	class Error < StandardError
	end
	
	def initialize(input)
		processInput(input)
	end
	
	def processInput(input)
		getTargets.each do |name, pattern, symbol|
			match = pattern.match(input)
			if match == nil
				errorMessage = "#{name} match failed"
				raise Error.new(errorMessage)
			end
			data = match[1]
			puts "#{name}: \"#{data}\" (#{match.size} match(es))" if debugging
			symbol = ('@' + symbol.to_s).to_sym
			instance_variable_set(symbol, data)
		end
		
		postProcessing(input)
	end
end
