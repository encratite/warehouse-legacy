require 'site/scene-access/SceneAccessSite'
require 'configuration/SceneAccess'

require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'

require 'configuration/Configuration'

def getReleaseSites
	return [
		SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent),
		TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent)
	]
end
