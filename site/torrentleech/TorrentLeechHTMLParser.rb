require 'shared/HTMLParser'

require 'site/torrentleech/TorrentLeechHTTPRelease'

class TorrentLeechHTMLParser < HTMLParser
	Pattern = /browse\.php\?cat=.+?alt=".+?"[\s\S]+?details\.php\?id=(\d+)&amp;.+?<b>(.+?)<\/b>/
	
	Symbols =
	[
		:siteId,
		:name,
	]
	
	def initialize
		super(TorrentLeechHTTPRelease)
	end
end
