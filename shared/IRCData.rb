class IRCData
	attr_reader :server, :port, :nick, :channels
	
	attr_writer :bot, :regexp
	
	def initialize(server, port, nick, channels)
		@server = server
		@port = port
		@nick = nick
		@channels = channels
	end
end
