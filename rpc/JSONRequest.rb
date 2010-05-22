require 'json'
require 'cgi'

class JSONRequest
	attr_reader :address, :requests, :cookies
	
	attr_writer :user
	
	def initialize(environment)
		@address = environment['HTTP_X_REAL_IP']
		
		@cookies = {}
		cookies = environment['HTTP_COOKIE']
		if cookies != nil
			cookieTokens = cookies.split(';').map { |token| token.strip }
			cookieTokens.each do |token|
				assignmentTokens = token.split '='
				next if assignmentTokens.size != 2
				variable, value = assignmentTokens
				value = CGI::unescape value
				@cookies[variable] = value
			end
		end
		
		@environment = environment
		
		@user = nil
	end
	
	def processJSON
		lines = environment['rack.input'].read.split("\n")
		@requests = lines.map{|x| JSON.parse(x)}
	end
	
	def isLoggedIn
		return @user != nil
	end
end
