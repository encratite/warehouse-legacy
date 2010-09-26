require 'shared/http/HTTPReleaseSite'

class TorrentLeechSite < HTTPReleaseSite
	def initialize(siteData, torrentData, connections, configuration)
		super(siteData, torrentData, connections, configuration)
		@nfoPath = siteData::HTTP::NFOPath
	end
	
	def processNewRelease(release)
		name = release.name
		idString = release.siteId.to_s
		detailsPath = sprintf(@detailsPath, idString)
		nfoPath = sprintf(@nfoPath, idString)
		paths = [detailsPath, nfoPath]
		output "Discovered a new release: #{name} (ID: #{release.siteId})"
		sleep @downloadDelay
		@releaseHandler.processReleasePaths(name, paths)
	end
end
