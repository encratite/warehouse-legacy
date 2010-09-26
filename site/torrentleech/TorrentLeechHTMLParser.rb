require_relative 'shared/HTMLParser'

require_relative 'site/torrentleech/TorrentLeechHTTPRelease'

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
