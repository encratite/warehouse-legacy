class TorrentLeechBrowser
	Pattern = /browse\.php\?cat=.+?alt="(.+?)".+?details.php\?id=(\d+)&amp;.+?<b>(.+?)<\/b>.+?#666666'>(.+?)<.+?<a href="(download\.php.+?)">.+?<td align="right">(\d+)<\/td>.+?<td align=center>(.+?)<br>(.+?)<\/td>.+?<td align=center>(\d+)<br>.+?<font color=#CCCCCC>(\d+)<\/font>.+?<td align=right><b>(\d+)<\/b><\/td>.+?<b>(.+?)<\/b>/
	
	Symbols =
	[
		:category,
		:site_id,
		:name,
		:date,
		:torrent_path,
		:comment_count,
		:size,
		:size_unit,
		:downloads,
		:seeders,
		:leechers,
		:seeders,
	]
end
