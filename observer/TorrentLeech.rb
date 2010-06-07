require 'site/torrentleech/TorrentLeechSite'
require 'configuration/TorrentLeech'
require 'configuration/Configuration'
require 'shared/ConnectionContainer'

site = TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, ConnectionContainer.new)
site.run
