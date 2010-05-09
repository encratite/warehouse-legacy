class IRCBot
	attr_reader :nick, :host
	
	def initialize(nick, host)
		@nick = nick
		@host = host
	end
	
	def ==(array)
		nick, host = array
		return @nick == nick && @host == host
	end
end
