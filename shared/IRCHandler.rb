class IRCHandler
	attr_reader :irc
	
	Debugging = false
	
	def initialize(data, releaseHandler)
		@releaseHandler = releaseHandler
		
		nick = data::Nick
		user = nick
		localHost = nick
		realName = nick
		
		@irc = Nil::IRCClient.new
		@irc.setServer(data::Server, data::Port)
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
	
	def postConsoleInitialisation(observer)
		@console = observer.console
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
			
		if Debugging
			puts "@releaseChannels.include?(channel): #{@releaseChannels.inspect}.include?(#{channel.inspect})"
			puts "user.nick == @botNick: #{user.nick.inspect} == #{@botNick.inspect}"
			puts "user.host == @botHost: #{user.host.inspect} == #{@botHost.inspect}"
		end
			
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
