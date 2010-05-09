class HTTPData
	attr_reader :server, :cookies
	
	def initialize(server, cookies)
		@server = server
		@cookies = cookies
	end
end
