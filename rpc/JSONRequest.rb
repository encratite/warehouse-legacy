require 'json'
require 'cgi'

require 'www-library/HTTPRequest'

class JSONRequest < HTTPRequest
	attr_reader :jsonRequests
	
	def initialize(environment)
		super(environment)
		
		lines = @rawInput.split("\n")
		@jsonRequests = lines.map{|x| JSON.parse(x)}
	end
end
