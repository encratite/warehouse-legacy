require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'
require 'configuration/Configuration'
require 'shared/database'

site = TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, getDatabase)
site.run
