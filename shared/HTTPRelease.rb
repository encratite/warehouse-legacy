class HTTPRelease
	class Error
		attr_reader :message
		
		def initialize(message)
			@message = message
		end
	end
	
	attr_reader :name, :siteId
	
	def initialize(data, symbols)
		if data.size != symbols.count
			raise "Match size/symbol count mismatch in a #{self.class}: #{match.inspect}"
		end
		
		offset = 0
		while offset < symbols.size
			symbol = ('@' + symbols[offset].to_s).to_sym
			value = data[offset]
			instance_variable_set(symbol, value)
			offset += 1
		end
	end
end
