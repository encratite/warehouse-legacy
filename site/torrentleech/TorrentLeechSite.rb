require 'shared/http/HTTPReleaseSite'

class TorrentLeechSite < HTTPReleaseSite
  def initialize(siteData, torrentData, connections, configuration)
    super(siteData, torrentData, connections, configuration)
  end

  def processNewRelease(release)
    name = release.name
    idString = release.siteId.to_s
    detailsPath = sprintf(@detailsPath, idString)
    output "Discovered a new release: #{name} (ID: #{release.siteId})"
    sleep @downloadDelay
    @releaseHandler.processReleasePath(name, detailsPath)
  end
end
