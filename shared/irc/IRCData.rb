require_relative 'shared/irc/IRCBot'
require_relative 'shared/irc/IRCRegexp'

class IRCData
	attr_reader :server, :port, :nick, :channels, :bots, :regexp
	
	def initialize(server, port, nick, channels, bots, releaseRegexp, urlRegexp)
		@server = server
		@port = port
		@nick = nick
		@channels = channels
		
		@bots = []
		bots.each do |bot|
			nick = bot[:nick]
			host = bot[:host]
			bot = IRCBot.new(nick, host)
			@bots << bot
		end
		
		@regexp = IRCRegexp.new(releaseRegexp, urlRegexp)
	end
end
