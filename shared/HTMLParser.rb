class HTMLParser
	def initialize(pattern, releaseClass)
		@pattern = pattern
		@releaseClass = releaseClass
	end
	
	def processData(html)
		output = []
		results.scan(@pattern) do |match|
			data = match[1..-1]
			release = @releaseClass.new(data, symbols)
			output << release
		end
		return output
	end
end
