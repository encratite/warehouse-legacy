require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'
require 'configuration/Configuration'
require 'shared/ConnectionContainer'

site = TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
site.run
