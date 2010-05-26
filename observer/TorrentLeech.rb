require 'site/torrentleech/TorrentLeechSite'
require 'configuration/TorrentLeech'
require 'configuration/Configuration'
require 'shared/database'

site = TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, getSQLDatabase)
site.run
