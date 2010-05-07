require 'HTTPHandler'
require 'SCCIRCHandler'
require 'ConsoleHandler'
require 'ReleaseHandler'
require 'SCCReleaseData'

class SCCManager
	attr_reader :http, :irc, :console, :releaseHandler, :configuration
	
	def initialize(configuration)
		@configuration = configuration
		
		cookieData = configuration::SceneAccess::Cookie
		uId = cookieData::UId
		pass = cookieData::Pass
		
		@http = HTTPHandler.new(uId, pass)
		
		ircData = configuration::SceneAccess::IRC
		server = ircData::Server
		nick = ircData::Nick
		
		channelConfiguration = configuration::SceneAccess::ReleaseChannel
		
		@releaseHandler = ReleaseHandler.new(self, configuration, :scene_access_data, SCCReleaseData)
		@irc = SCCIRCHandler.new(channelConfiguration, self, server, nick)
		@console = ConsoleHandler.new(self)
		@irc.postConsoleInitialisation(self)
	end
	
	def run
		@irc.run
		@console.run
	end
end
