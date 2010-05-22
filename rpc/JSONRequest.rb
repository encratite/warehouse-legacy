require 'json'
require 'cgi'

require 'www-library/HTTPRequest'

class JSONRequest < HTTPRequest
	attr_reader :jsonRequests
	
	def initialize(environment)
		super(environment)
		processJSON
	end
	
	def processJSON
		lines = environment['rack.input'].read.split("\n")
		@jsonRequests = lines.map{|x| JSON.parse(x)}
	end
end
