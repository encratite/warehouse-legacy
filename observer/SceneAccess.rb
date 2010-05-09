require 'site/scene-access/SceneAccessSite'
require 'configuration/SceneAccess'
require 'configuration/Configuration'

site = SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent)
site.run
