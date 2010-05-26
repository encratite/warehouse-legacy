require 'site/scene-access/SceneAccessSite'
require 'configuration/SceneAccess'
require 'configuration/Configuration'
require 'shared/sqlDatabase'

site = SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, getSQLDatabase)
site.run
