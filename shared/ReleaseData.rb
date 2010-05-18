class ReleaseData
	attr_reader :name, :path, :size, :nfo, :genre
	
	class Error < StandardError
	end
	
	def initialize(input)
		processInput(input)
	end
	
	def processInput(input)
		debugging = self.class::Debugging
		targets = self.class::Targets
		
		requiredFlagOffset = 3
		targets.each do |data|
			name, pattern, symbol = data
			if data.size > requiredFlagOffset
				isRequired = data[requiredFlagOffset]
			else
				isRequired = true
			end
			match = pattern.match(input)
			if match == nil
				next if !isRequired
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
