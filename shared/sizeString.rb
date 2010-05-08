require 'nil/string'

def convertSizeString(input)	
	tokens = input.split(' ')
	raise "Invalid token count in size string: #{input}" if tokens.size != 2
	valueString = tokens[0]
	raise "Invalid value string in size string: #{valueString}" if !valueString.isNumber
	value = valueString.to_f
	unit = tokens[1].upcase
		
	units =
	[
		'B',
		'KB',
		'MB',
		'GB'
	]
	
	factor = 1024
	
	unitOffset = units.index(unit)
	raise "Invalid unit in size string: #{unit}" if unitOffset == nil
	
	size = (value * (factor ** unitOffset)).to_i
	return size
end
