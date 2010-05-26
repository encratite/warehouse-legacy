require 'site/scene-access/SceneAccessSite'
require 'configuration/SceneAccess'
require 'configuration/Configuration'
require 'shared/database'

site = SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, getSQLDatabase)
site.run
