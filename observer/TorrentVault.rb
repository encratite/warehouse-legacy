require_relative 'site/torrentvault/TorrentVaultSite'
require_relative 'configuration/TorrentVault'
require_relative 'configuration/Configuration'
require_relative 'shared/ConnectionContainer'

site = TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
site.run
