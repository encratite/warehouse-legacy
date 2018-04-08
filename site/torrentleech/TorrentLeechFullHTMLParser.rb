require 'json'

require 'shared/HTMLParser'

require 'site/torrentleech/TorrentLeechFullHTTPRelease'

class TorrentLeechFullHTMLParser < HTMLParser
  def initialize
    super(TorrentLeechFullHTTPRelease)
  end
  
  def processData(json)
    data = JSON.parse(json)
	torrents = data["torrentList"]
	output = torrents.map { |torrentData| TorrentLeechFullHTTPRelease.new(torrentData) }
	return output
  end
end
