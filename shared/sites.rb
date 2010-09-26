require_relative 'site/sceneaccess/SceneAccessSite'
require_relative 'configuration/SceneAccess'

require_relative 'site/torrentvault/TorrentVaultSite'
require_relative 'configuration/TorrentVault'

require_relative 'site/torrentleech/TorrentLeechSite'
require_relative 'configuration/TorrentLeech'

require_relative 'configuration/Configuration'

def getReleaseSites(connections)
	return [
		SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, connections, Configuration),
		TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, connections, Configuration),
		TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, connections, Configuration),
	]
end
