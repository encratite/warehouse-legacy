require 'shared/HTMLParser'

require 'site/torrentleech/TorrentLeechHTTPRelease'

class TorrentLeechHTMLParser < HTMLParser
	Pattern = /download\.php\/(\d+)\/(.+?)\.torrent/
	
	Symbols =
	[
		:siteId,
		:name,
	]
	
	def initialize
		super(TorrentLeechHTTPRelease)
	end
end
