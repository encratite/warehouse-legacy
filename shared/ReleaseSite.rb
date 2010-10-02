require 'nil/http'

require 'shared/ReleaseHandler'
require 'shared/OutputHandler'

require 'shared/irc/IRCData'

require 'shared/logging'

class ReleaseSite
	#database/connections reader required by the ReleaseHandler
	attr_reader :log, :table, :name, :abbreviation, :database, :connections
	attr_reader :httpHandler, :outputHandler, :releaseHandler, :dataset
	
	#Used by ReleaseHandler
	attr_reader :torrentPath, :releaseSizeLimit, :releaseDataClass
	
	def initialize(siteData, torrentData, connections, configuration)
		@connections = connections
		@database = connections.sqlDatabase
		@log = getSiteLogPath(siteData::Log)
		@table = siteData::Table
		@name = siteData::Name
		@abbreviation = siteData::Abbreviation
		@dataset = database[@table]
		
		@torrentPath = torrentData::Path::Torrent
		@releaseSizeLimit = torrentData::SizeLimit
		
		@releaseDataClass = siteData::ReleaseDataClass
		
		http = siteData::HTTP
		@httpHandler = Nil::HTTP.new(http::Server, http::Cookies)
		@httpHandler.ssl = http::SSL
		@outputHandler = OutputHandler.new(@log)
		@releaseHandler = ReleaseHandler.new(self, connections, configuration::API)
	end
	
	def ==(abbreviation)
		return @abbreviation.downcase == abbreviation.downcase
	end
end
