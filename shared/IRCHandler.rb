class IRCHandler
	attr_reader :irc
	
	def initialize(data)
		@http = manager.http
		@releaseHandler = manager.releaseHandler
		
		nick = data::Nick
		user = nick
		localHost = nick
		realName = nick
		
		@irc = Nil::IRCClient.new
		@irc.setServer(data::Server)
		@irc.setUser(nick, user, localHost, realName)
		@irc.onEntry = method(:onEntry)
		@irc.onChannelMessage = method(:onChannelMessage)
		
		@releaseChannels = data::Channels
		@botNick = data::Bot::Nick
		@botHost = data::Bot::Host
		
		regexp = data::Regexp
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
	
	def onChannelMessage(channel, user, message)
		isBotMessage =
			@releaseChannels.include?(channel) &&
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
