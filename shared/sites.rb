require 'site/sceneaccess/SceneAccessSite'
require 'configuration/SceneAccess'

require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'

require 'site/torrentleech/TorrentLeechSite'
require 'configuration/TorrentLeech'

require 'configuration/Configuration'

def getReleaseSites(connections)
  return [
          TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, connections, Configuration),
          #SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, connections, Configuration),
          TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, connections, Configuration),
         ]
end
