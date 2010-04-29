require 'nil/irc'

class IRCHandler
	attr_reader :irc
	
	def initialize(channel, manager, server, nick)
		@http = manager.http
		@releaseHandler = manager.releaseHandler
		
		user = nick
		localHost = nick
		realName = nick
		@irc = Nil::IRCClient.new
		@irc.setServer(server)
		@irc.setUser(nick, user, localHost, realName)
		@irc.onEntry = method(:onEntry)
		@irc.onChannelMessage = method(:onChannelMessage)
		
		@releaseChannel = channel::Channel
		@botNick = channel::Nick
		@botHost = channel::Host
		
		regexp = channel::Regexp
		@releasePattern = regexp::Release
		@urlPattern = regexp::URL
	end
	
	def postConsoleInitialisation(manager)
		@console = manager.console
		@irc.onLine = @console.method(:onLine)
		@irc.onSendLine = @console.method(:onSendLine)
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
	
	def onChannelMessage(channel, user, message)
		isBotMessage =
			channel == @releaseChannel &&
			user.nick == @botNick &&
			user.host == @botHost
		if isBotMessage
			message = Nil::IRCClient::stripTags(message)
			releaseMatch = @releasePattern.match(message)
			urlMatch = @urlPattern.match(message)
			if releaseMatch != nil && urlMatch != nil
				release = releaseMatch[1]
				url = urlMatch[1]
				@releaseHandler.processMessage(release, url)
			end
		end
		@console.onChannelMessage(channel, user, message)
	end
end
