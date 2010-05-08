require 'HTTPHandler'
require 'SCCIRCHandler'
require 'ConsoleHandler'
require 'ReleaseHandler'
require 'SCCReleaseData'

class SCCManager
	attr_reader :http, :irc, :console, :releaseHandler, :configuration
	
	def initialize(configuration)
		@configuration = configuration
		
		scc = configuration::SceneAcces
		http = scc::HTTP
		@http = HTTPHandler.new(http::Server, http::Cookies)
		@releaseHandler = ReleaseHandler.new(self, configuration, :scene_access_data, SCCReleaseData)
		@irc = SCCIRCHandler.new(scc::IRC)
		@console = ConsoleHandler.new(self)
		@irc.postConsoleInitialisation(self)
	end
	
	def run
		@irc.run
		@console.run
	end
end
