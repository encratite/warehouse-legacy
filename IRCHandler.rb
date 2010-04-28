require 'nil/irc'

class IRCHandler
	attr_reader :irc
	
	def initialize(manager, server, nick)
		@http = manager.http
		
		user = nick
		localHost = nick
		realName = nick
		@irc = Nil::IRCClient.new
		@irc.setServer(server)
		@irc.setUser(nick, user, localHost, realName)
		@irc.onEntry = method(:onEntry)
	end
	
	def postConsoleInitialisation(manager)
		@console = manager.console
	end
	
	def run
		@irc.start
	end
	
	def onEntry
		data =
		{
			'announce' => 'yes',
			'invite' => 'invite'
		}
		@http.post('/irc.php', data)
		
		@console.onEntry
	end
end
