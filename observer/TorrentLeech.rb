require 'site/torrentleech/TorrentLeechSite'
require 'configuration/TorrentLeech'
require 'configuration/Configuration'
require 'shared/database'

site = TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, getDatabase)
site.run
