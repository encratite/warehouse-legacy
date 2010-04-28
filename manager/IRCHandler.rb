require 'nil/irc'

class IRCHandler
	attr_reader :irc
	
	def initialize(channelConfiguration, manager, server, nick)
		@http = manager.http
		@releaseHandler = manager.releaseHandler
		
		user = nick
		localHost = nick
		realName = nick
		@irc = Nil::IRCClient.new
		@irc.setServer(server)
		@irc.setUser(nick, user, localHost, realName)
		@irc.onEntry = method(:onEntry)
		
		@releaseChannel = channelConfiguration.const_get(:Channel)
		@botNick = channelConfiguration.const_get(:Nick)
		@botHost = channelConfiguration.const_get(:Host)
		
		regexpConfiguration = channelConfiguration.const_get(:Regexp)
		@releasePattern = regexpConfiguration.const_get(:Release)
		@urlPattern = regexpConfiguration.const_get(:URL)
	end
	
	def postConsoleInitialisation(manager)
		@console = manager.console
		@irc.onLine = @console.method(:onLine)
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
			releaseMatch = @releasePattern.match(message)
			urlMatch = @urlPattern.match(message)
			if releaseMatch != nil && urlMatch != nil
				release = releaseMatch[1]
				url = urlMatch[1]
				@releaseHandler.processMessage(relase, url)
			end
		end
		@console.onChannelMessage(channel, user, message)
	end
end
