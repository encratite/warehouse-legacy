require 'shared/HTMLParser'

require 'site/torrentleech/TorrentLeechHTTPRelease'

class TorrentLeechHTMLParser < HTMLParser
	Pattern = /<a href="\/torrent\/(\d+)">(.+?)<\/a>/
	
	Symbols =
	[
		:siteId,
		:name,
	]
	
	def initialize
		super(TorrentLeechHTTPRelease)
	end
end
