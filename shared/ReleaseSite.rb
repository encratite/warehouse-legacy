require 'HTTPHandler'
require 'IRCHandler'
require 'ReleaseHandler'
require 'OutputHandler'
require 'ConsoleHandler'

require 'IRCData'

require 'database'
require 'logging'

class ReleaseSite
	attr_reader :log, :table, :name, :abbreviation, :database
	attr_reader :httpHandler, :outputHandler, :releaseHandler, :ircHandler
	
	def initialize(siteData)
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
		@abbreviation = siteData::Abreviation
		@database = getDatabase
		
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
		@ircHandler = IRCHandler
	end
end
