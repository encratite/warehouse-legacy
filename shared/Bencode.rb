require 'nil/string'

class Bencode
	attr_accessor :units
	
	def initialize(input)
		@input = input
		@offset = 0
		@units = []
		processData
	end
	
	def processData
		while @offset < @input.size
			unit = readUnit
			@units << unit
		end
	end
	
	def nextByte
		return nil if @offset >= @input.size
		return @input[@offset]
	end
	
	def readUnit
		letter = nextByte
		case letter
		when 'i'
			return readInteger
		when 'l'
			return readList
		when 'd'
			return readDictionary
		when 'e'
			#terminator of dictionaries/lists
			@offset += 1
			return nil
		when nil
			raise 'Incomplete list/dictionary'
		else
			if letter.isNumber
				return readString
			else
				raise "Invalid unit type: #{letter}"
			end
		end
	end
	
	def readInteger
		#integer: i<digits>e
		@offset += 1
		offset = @input.index('e', @offset)
		raise 'Non-terminated integer' if offset == nil
		numberString = @input[@offset..(offset - 1)]
		raise "Invalid integer length: #{numberString}" if !numberString.isNumber
		number = numberString.to_i
		@offset = offset + 1
		return number
	end
	
	def readList
		output = []
		@offset += 1
		while true
			unit = readUnit
			return output if unit == nil
			output << unit
		end
	end
	
	def readDictionary
		output = {}
		@offset += 1
		while true
			key = readUnit
			return output if key == nil
			value = readUnit
			output[key] = value
		end
	end
	
	def readString
		#<length digits>:<content of legth specified by the previous field>
		offset = @input.index(':', @offset + 1)
		raise 'Non-terminated string' if offset == nil
		numberString = @input[@offset..(offset - 1)]
		raise "Invalid string length: #{numberString}" if !numberString.isNumber
		number = numberString.to_i
		@offset = offset + 1
		newOffset = @offset + number
		raise "Invalid string length: #{number}" if newOffset >= @input.size
		string = @input[@offset..(newOffset - 1)]
		@offset = newOffset
		return string
	end
	
	def getOutput
		@output = ''
		@units.each do |unit|
			serialise(unit)
		end
		return @output
	end
	
	def serialise(unit)
		case unit
		when String
			@output.concat "#{unit.size}:#{unit}"
		when Fixnum
			writeNumber(unit)
		when Bignum
			writeNumber(unit)
		when Array
			@output.concat 'l'
			unit.each do |element|
				serialise element
			end
			@output.concat 'e'
		when Hash
			@output.concat 'd'
			unit.each do |key, value|
				serialise key
				serialise value
			end
			@output.concat 'e'
		else
			raise "Encountered an invalid type: #{unit.class}"
		end
	end
	
	def writeNumber(unit)
		@output.concat "i#{unit}e"
	end
	
	def self.getTorrentName(input)
		units = nil
		begin
			units = Bencode.new(input).units
		rescue RuntimeError => exception
			error "Bencode error in torrent file: #{exception.message}"
		end
		if units.empty?
			raise 'Empty torrent file'
		end
		mainDictionary = units[0]
		if mainDictionary.class != Hash
			raise 'Torrent data is not a dictionary'
		end
		info = mainDictionary['info']
		if info == nil
			raise 'The torrent has no info field'
		end
		if info.class != Hash
			raise 'The info field is not a dictionary'
		end
		name = info['name']
		if name == nil
			raise 'Unable to determine torrent name - field is not specified'
		end
		torrent = "#{name}.torrent"
		return torrent
	end
end
