require 'json'

require 'shared/HTMLParser'

require 'site/torrentleech/TorrentLeechHTTPRelease'

class TorrentLeechHTMLParser < HTMLParser
  def initialize
    super(TorrentLeechHTTPRelease)
  end
  
  def processData(json)
    begin
	  data = JSON.parse(json)
	  torrents = data["torrentList"]
	  output = torrents.map { |torrentData| TorrentLeechHTTPRelease.new(torrentData) }
	  return output
    rescue JSON::ParserError => error
	  puts "Failed to process JSON: " + error.message
	  return []
	end
  end
end
