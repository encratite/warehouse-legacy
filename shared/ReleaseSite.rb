require 'shared/HTTPHandler'
require 'shared/ReleaseHandler'
require 'shared/OutputHandler'

require 'shared/IRCData'

require 'shared/database'
require 'shared/logging'

class ReleaseSite
	attr_reader :log, :table, :name, :abbreviation, :database
	attr_reader :httpHandler, :outputHandler, :releaseHandler
	
	#Used by ReleaseHandler
	attr_reader :torrentPath, :releaseSizeLimit, :releaseDataClass
	
	def initialize(siteData, torrentData, database)
		"""
		Dependencies:
		HTTPHandler: None
		OutputHandler: None
		ReleaseHandler: HTTPHandler, OutputHandler
		"""

		@database = database
		@log = getSiteLogPath(siteData::Log)
		@table = siteData::Table
		@name = siteData::Name
		@abbreviation = siteData::Abbreviation
		@dataset = database[@table]
		
		@torrentPath = torrentData::Path::Torrent
		@releaseSizeLimit = torrentData::SizeLimit
		
		@releaseDataClass = siteData::ReleaseDataClass
		
		http = siteData::HTTP
		@httpHandler = HTTPHandler.new(http::Server, http::Cookies)
		@outputHandler = OutputHandler.new(@log)
		@releaseHandler = ReleaseHandler.new(self)
	end
	
	def ==(abbreviation)
		return @abbreviation.downcase == abbreviation.downcase
	end
end
