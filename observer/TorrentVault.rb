require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'
require 'configuration/Configuration'
require 'shared/sqlDatabase'

site = TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, getSQLDatabase)
site.run
