require 'shared/HTTPRelease'

class HTMLParser
	def initialize(releaseClass = HTTPRelease)
		@releaseClass = releaseClass
	end
	
	def processData(html)
		output = []
		results.scan(self.class::Pattern) do |match|
			data = match[1..-1]
			release = @releaseClass.new(data, self.class::Symbols)
			output << release
		end
		return output
	end
end
