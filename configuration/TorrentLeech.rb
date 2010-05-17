require 'site/TorrentLeech/TorrentLeechReleaseData'

require 'secret/TorrentLeech'

module TorrentLeechConfiguration
	module HTTP
		Server = 'torrentleech.org'
		BrowsePath = '/browse.php'
		#Cookies are secret
	end
	
	Log = 'TorrentLeech.log'
	Table = :torrentleech_data
	Name = 'TorrentLeech'
	Abbreviation = 'TL'
	
	ReleaseDataClass = TorrentLeechReleaseData
end
