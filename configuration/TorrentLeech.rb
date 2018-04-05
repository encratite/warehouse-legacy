require 'site/torrentleech/TorrentLeechReleaseData'
require 'site/torrentleech/TorrentLeechHTMLParser'

require 'secret/TorrentLeech'

module TorrentLeechConfiguration
  module HTTP
    Server = 'classic.torrentleech.org'
    BrowsePath = '/torrents/browse'
    DetailsPath = '/torrent/%s'

    #Cookies are secret
    SSL = true
  end

  Log = 'torrentleech.log'
  Table = :torrentleech_data
  Name = 'TorrentLeech'
  Abbreviation = 'TL'

  ReleaseDataClass = TorrentLeechReleaseData
  HTMLParserClass = TorrentLeechHTMLParser
end
