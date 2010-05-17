require 'shared/ReleaseSite'

class HTTPReleaseSite < ReleaseSite
	def initialize(siteData, torrentData)
		super(siteData, torrentData)
		
		httpData = torrentData::HTTP
		@browseDelay = httpData::BrowseDelay
		@downloadDelay = httpData::DownloadDelay
	end
end
