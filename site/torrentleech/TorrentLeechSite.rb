require 'shared/HTTPReleaseSite'

class TorrentLeechSite < HTTPReleaseSite
	def initialize(siteData, torrentData)
		super(siteData, torrentData)
	end
end
