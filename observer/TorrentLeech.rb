require 'site/torrentleech/TorrentLeechSite'
require 'configuration/TorrentLeech'
require 'configuration/Configuration'
require 'shared/sqlDatabase'

site = TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, getSQLDatabase)
site.run
