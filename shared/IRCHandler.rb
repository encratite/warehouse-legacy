class IRCHandler
	attr_reader :irc
	
	def initialize(site)
		@releaseHandler = site.releaseHandler
		
		ircData = site.ircData
		nick = ircData.nick
		user = nick
		localHost = nick
		realName = nick
		
		@irc = Nil::IRCClient.new
		@irc.setServer(ircData.server, ircData.port)
		@irc.setUser(nick, user, localHost, realName)
		@irc.onEntry = method(:onEntry)
		@irc.onChannelMessage = method(:onChannelMessage)
		
		@releaseChannels = ircData.channels
		@bots = ircData.bots
		
		regexp = ircData.regexp
		@releasePattern = regexp.release
		@urlPattern = regexp.url
		
		outputHandler = site.outputHandler
		@irc.onLine = outputHandler.method(:onLine)
		@irc.onSendLine = outputHandler.method(:onSendLine)
	end
	
	def run
		@irc.start
	end
	
	def onChannelMessage(channel, user, message)
		channelMatch = @releaseChannels.include?(channel)
		identifier = [user.nick, user.host]
		userMatch = @bots.include?(identifier)
		isBotMessage = channelMatch && userMatch

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
