require 'shared/HTTPHandler'
require 'shared/IRCHandler'
require 'shared/ReleaseHandler'
require 'shared/OutputHandler'
require 'shared/ConsoleHandler'

require 'shared/IRCData'

require 'shared/database'
require 'shared/logging'

class ReleaseSite
	attr_reader :log, :table, :name, :abbreviation, :database
	attr_reader :httpHandler, :outputHandler, :releaseHandler, :ircHandler
	
	#Used by ReleaseHandler
	attr_reader :torrentPath, :releaseSizeLimit, :releaseDataClass
	
	#Used by IRCHandler
	attr_reader :ircData
	
	def initialize(siteData, torrentData)
		"""
		Dependencies:
		HTTPHandler: None
		OutputHandler: None
		ReleaseHandler: HTTPHandler, OutputHandler
		IRCHandler: OutputHandler, ReleaseHandler
		ConsoleHandler: IRCHandler
		"""

		@log = getSiteLogPath(siteData::Log)
		@table = siteData::Table
		@name = siteData::Name
		@abbreviation = siteData::Abbreviation
		@database = getDatabase
		
		@torrentPath = torrentData::Path::Torrent
		@releaseSizeLimit = torrentData::SizeLimit
		
		@releaseDataClass = siteData::ReleaseDataClass
		@ircHandlerClass = siteData::IRCHandlerClass
		
		ircData = siteData::IRC
		regexpData = ircData::Regexp
		@ircData = IRCData.new(
			ircData::Server,
			ircData::Port,
			ircData::Nick,
			ircData::Channels,
			ircData::Bots,
			regexpData::Release,
			regexpData::URL
		)
		
		http = siteData::HTTP
		@httpHandler = HTTPHandler.new(http::Server, http::Cookies)
		@outputHandler = OutputHandler.new(@log)
		@releaseHandler = ReleaseHandler.new(self)
		@ircHandler = @ircHandlerClass.new(self)
		@consoleHandler = ConsoleHandler.new(@ircHandler)
	end
	
	def run
		@ircHandler.run
		@consoleHandler.run
	end
	
	def ==(abbreviation)
		return @abbreviation.downcase == abbreviation.downcase
	end
end
