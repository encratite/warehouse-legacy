require 'shared/ReleaseSite'

class HTTPReleaseSite < ReleaseSite
	def initialize(siteData, torrentData)
		super(siteData, torrentData)
		
		httpData = torrentData::HTTP
		@browsePath = httpData::BrowsePath
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
			output "Failed to retrieve #{@browsePath}"
			return
		end
		
		releases = @htmlParser.processData(data)
		if releases.empty?
			output "Failed to retrieve any releases from #{@browsePath}"
			return
		end
		output "Retrieved #{releases.size} releases from #{@browsePath}"
		releases.each do |release|
			result = @dataset.where(site_id: release.site_d)
			#check if this release is already in the database
			next if !result.empty?
			processNewRelease release
		end
	end
	
	def processNewRelease(release)
		output "Discovered a new release: #{release.name}"
		path = "/details.php?id=#{release.siteId}&hit=1"
		#sleep here, in order to enforce a minimal delay between most of the queries to mimic humans
		sleep @downloadDelay
		data = @httpHandler.get(path)
		if data == nil
			output "Failed to download the details for release #{release.name} from #{path}"
			return
		end
		
		releaseData = @releaseDataClass.new(data)
	end
	
	def run
		while @running
			browse
			sleep @browseDelay
		end
	end
end
