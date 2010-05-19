require 'shared/ReleaseSite'

class HTTPReleaseSite < ReleaseSite
	def initialize(siteData, torrentData)
		super(siteData, torrentData)
		
		@browsePath = siteData::HTTP::BrowsePath
		
		httpData = torrentData::HTTP
		@browseDelay = httpData::BrowseDelay
		@downloadDelay = httpData::DownloadDelay
		@parserTimeout = httpData::ParserTimeout
		
		@htmlParser = siteData::HTMLParserClass.new
		
		@running = true
	end
	
	def output(line)
		@outputHandler.output(line)
	end
	
	def browse
		data = @httpHandler.get(@browsePath)
		if data == nil
			output "Error: Failed to retrieve #{@browsePath}"
			return
		end
		
		#puts data
		
		releases = @htmlParser.processData(data)
		if releases.empty?
			output "Error: Failed to retrieve any releases from #{@browsePath}"
			return
		end
		output "Retrieved #{releases.size} releases from #{@browsePath}"
		releases.each do |release|
			result = @dataset.where(site_id: release.siteId)
			#check if this release is already in the database
			next if !result.empty?
			processNewRelease release
		end
	end
	
	def processNewRelease(release)
		name = release.name
		path = "/details.php?id=#{release.siteId}"

		output "Discovered a new release: #{name}"
		#sleep here, in order to enforce a minimal delay between most of the queries to mimic humans
		sleep @downloadDelay
		@releaseHandler.processReleasePath(name, path)
	end
	
	def run
		while @running
			browse
			sleep @browseDelay
		end
	end
end
