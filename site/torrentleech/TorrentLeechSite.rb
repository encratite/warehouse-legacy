require 'shared/ReleaseSite'

class TorrentLeechSite < ReleaseSite
	def initialize(siteData, torrentData)
		super(siteData, torrentData)
	end
end
