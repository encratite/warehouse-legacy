require 'site/scene-access/SceneAccessSite'
require 'configuration/SceneAccess'

require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'

require 'site/torrentleech/TorrentLeechSite'
require 'configuration/TorrentLeech'

require 'configuration/Configuration'

def getReleaseSites(database)
	return [
		SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, database),
		TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, database),
		TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, database),
	]
end
