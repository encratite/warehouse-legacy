class HTTPRelease
	def initialize(data)
		symbols = getSymbols
		if data.size != @ymbols.count
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
	
	def getSymbols
		return self.class::Symbols
	end
end
