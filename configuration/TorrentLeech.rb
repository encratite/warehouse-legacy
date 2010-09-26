require 'site/torrentleech/TorrentLeechReleaseData'
require 'site/torrentleech/TorrentLeechHTMLParser'

require 'secret/TorrentLeech'

module TorrentLeechConfiguration
	module HTTP
		Server = 'www.torrentleech.org'
		BrowsePath = '/browse.php'
		DetailsPath = '/details.php?id=%s'
		NFOPath = '/viewnfo.php?id=%s'
		
		#Cookies are secret
	end
	
	Log = 'torrentleech.log'
	Table = :torrentleech_data
	Name = 'TorrentLeech'
	Abbreviation = 'TL'
	
	ReleaseDataClass = TorrentLeechReleaseData
	HTMLParserClass = TorrentLeechHTMLParser
end
