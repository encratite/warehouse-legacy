class IRCBot
	attr_reader :nick, :host
	
	def initialize(nick, host)
		@nick = nick
		@host = host
	end
end
