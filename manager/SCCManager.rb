require 'HTTPHandler'
require 'IRCHandler'
require 'ConsoleHandler'
require 'ReleaseHandler'

class SCCManager
	attr_reader :http, :irc, :console, :releaseHandler, :configuration
	
	def initialize(configuration)
		@configuration = configuration
		
		cookieData = configuration::Cookie
		uId = cookieData::UId
		pass = cookieData::Pass
		
		@http = HTTPHandler.new(uId, pass)
		
		ircData = configuration::IRC
		server = ircData::Server
		nick = ircData::Nick
		
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
