require 'nil/file'

class ReleaseObserver
	attr_reader :http, :irc, :console, :releaseHandler, :configuration
	
	def initialize(configuration)
		@configuration = configuration
		siteInitialisation
	end
	
	def createObjects(siteConfiguration, releaseTableSymbol, releaseDataClass)
		http = siteConfiguration::HTTP
		@http = HTTPHandler.new(http::Server, http::Cookies)
		@releaseHandler = ReleaseHandler.new(self, @configuration, releaseTableSymbol, releaseDataClass)
		@irc = SCCIRCHandler.new(siteConfiguration::IRC)
		logPath = Nil.joinPaths(@configuration::Logging::SitePath, siteConfiguration::Log)
		@console = ConsoleHandler.new(@irc, logPath)
		@irc.postConsoleInitialisation(self)
	end
	
	def run
		@irc.run
		@console.run
	end
end
