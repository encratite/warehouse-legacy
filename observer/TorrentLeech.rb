require_relative 'site/torrentleech/TorrentLeechSite'
require_relative 'configuration/TorrentLeech'
require_relative 'configuration/Configuration'
require_relative 'shared/ConnectionContainer'

site = TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
site.run
