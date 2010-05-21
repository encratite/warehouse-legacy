require 'shared/HTMLParser'

require 'site/torrentleech/TorrentLeechHTTPRelease'

class TorrentLeechHTMLParser < HTMLParser
	#Pattern = /browse\.php\?cat=.+?alt="(.+?)"[\s\S]+?details\.php\?id=(\d+)&amp;.+?<b>(.+?)<\/b>.+?#666666'>(.+?)<\/font>[\s\S]+?<a href="(download\.php.+?)">[\s\S]+?<td align="right".*?>(\d+)<.*?\/td>[\s\S]+?<td align=center>(.+?)<br>(.+?)<\/td>[\s\S]+?<td align=center>(\d+)<br>[\s\S]+?>(\d+)<[\s\S]+?>(\d+)<[\s\S]+?<td align=center>(.+?)<\/td>/
	Pattern = /browse\.php\?cat=.+?alt=".+?"[\s\S]+?details\.php\?id=(\d+)&amp;.+?<b>(.+?)<\/b>/
	
	Symbols =
	[
		#:category,
		:siteId,
		:name,
		#:date,
		#:torrentPath,
		#:commentCount,
		#:size,
		#:sizeUnit,
		#:downloads,
		#:seeders,
		#:leechers,
		#:seeders,
	]
	
	def initialize
		super(TorrentLeechHTTPRelease)
	end
end
