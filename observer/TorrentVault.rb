require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'
require 'configuration/Configuration'

site = TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent)
site.run
