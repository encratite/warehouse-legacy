require 'site/torrentleech/TorrentLeechSite'
require 'configuration/TorrentLeech'
require 'configuration/Configuration'

site = TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent)
site.run
