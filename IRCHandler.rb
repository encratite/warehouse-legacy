require 'nil/irc'

class IRCHandler
	attr_reader :irc
	
	def initialize(server, nick)
		user = nick
		localHost = nick
		realName = nick
		@irc = Nil::IRCClient.new
		@irc.setServer(server)
		@irc.setUser(nick, user, localHost, realName)
		@irc.onLine = method(:onLine)
	end
	
	def run
		@irc.start
	end
end
