require 'shared/HTMLParser'

require 'site/torrentleech/TorrentLeechFullHTTPRelease'

class TorrentLeechFullHTMLParser < HTMLParser
  Pattern = /<tr class="even" id=(\d+)>.*<a href="\/torrent\/\d+">(.+?)<\/a>.+Added in <b>(.+?)<\/b> on (.+?)<\/td>.+?<a href="(\/download\/\d+\/.+?\.torrent)">.+?<td>(\d+) (KB|MB|GB)<\/td>.+?<td>(\d+)<br>times<\/td>.+?<td class="seeders">(\d+)<\/td>.+?<td class="leechers">(\d+)<\/td>/m

  Symbols =
    [
    :siteId,
    :name,
    :category,
    :date,
    :torrentPath,
    :size,
    :sizeUnit,
    :downloads,
    :seeders,
    :leechers
  ]

  def initialize
    super(TorrentLeechFullHTTPRelease)
  end
end
