require 'HTTPHandler'
require 'IRCHandler'
require 'ConsoleHandler'
require 'ReleaseHandler'

class SCCManager
	attr_reader :http, :irc, :console, :releaseHandler
	
	def initialize(configuration)
		cookieData = configuration.const_get(:Cookie)
		uId = cookieData.const_get(:UId)
		pass = cookieData.const_get(:Pass)
		
		@http = HTTPHandler.new(uId, pass)
		
		ircData = configuration.const_get(:IRC)
		server = ircData.const_get(:Server)
		nick = ircData.const_get(:Nick)
		
		channelConfiguration = configuration.const_get(:ReleaseChannel)
		
		@releaseHandler = ReleaseHandler.new(self, configuration)
		@irc = IRCHandler.new(channelConfiguration, self, server, nick)
		@console = ConsoleHandler.new(self)
		@irc.postConsoleInitialisation(self)
	end
	
	def run
		@irc.run
		@console.run
	end
end
