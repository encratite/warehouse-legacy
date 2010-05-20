require 'shared/HTMLParser'

class TorrentLeechHTMLParser < HTMLParser
	#Pattern = /browse\.php\?cat=.+?alt="(.+?)"[\s\S]+?details\.php\?id=(\d+)&amp;.+?<b>(.+?)<\/b>.+?#666666'>(.+?)<\/font>[\s\S]+?<a href="(download\.php.+?)">[\s\S]+?<td align="right">(\d+)<\/td>[\s\S]+?<td align=center>(.+?)<br>(.+?)<\/td>[\s\S]+?<td align=center>(\d+)<br>.+?<font color=#CCCCCC>(\d+)<\/font>[\s\S]+?<td align=right><b>(\d+)<\/b><\/td>[\s\S]+?<b>(.+?)<\/b>/
	Pattern = /browse\.php\?cat=.+?alt="(.+?)"[\s\S]+?details\.php\?id=(\d+)&amp;.+?<b>(.+?)<\/b>.+?#666666'>(.+?)<\/font>[\s\S]+?<a href="(download\.php.+?)">[\s\S]+?<td align="right">(\d+)<\/td>[\s\S]+?<td align=center>(.+?)<br>(.+?)<\/td>[\s\S]+?<td align=center>(\d+)<br>.+?<\/td>[\s\S]+?<font color=#CCCCCC>(\d+)<\/font>[\s\S]+?<td align=right><b>(\d+)<\/b><\/td>[\s\S]+?<b>(.+?)<\/b>/
	
	Symbols =
	[
		:category,
		:siteId,
		:name,
		:date,
		:torrentPath,
		:commentCount,
		:size,
		:sizeUnit,
		:downloads,
		:seeders,
		:leechers,
		:seeders,
	]
end
