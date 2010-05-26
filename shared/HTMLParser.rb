require 'shared/http/HTTPRelease'

class HTMLParser
	def initialize(releaseClass = HTTPRelease)
		@releaseClass = releaseClass
	end
	
	def processData(html)
		output = []
		results = html.scan(self.class::Pattern)
		puts "Result count: #{results.size}"
		results.each do |match|
			release = @releaseClass.new(match, self.class::Symbols)
			output << release
		end
		return output
	end
end
