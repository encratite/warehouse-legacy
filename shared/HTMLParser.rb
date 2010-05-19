require 'shared/HTTPRelease'

class HTMLParser
	def initialize(releaseClass = HTTPRelease)
		@releaseClass = releaseClass
	end
	
	def processData(html)
		output = []
		html = html.gsub(/[\n\r]/, '')
		html.scan(self.class::Pattern) do |match|
			#puts "Got a match: #{match.inspect}"
			release = @releaseClass.new(match, self.class::Symbols)
			output << release
		end
		return output
	end
end
