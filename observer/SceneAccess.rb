require 'site/scene-access/SCCSite'
require 'configuration/SceneAccess'
require 'configuration/Configuration'

site = SCCSite.new(SceneAccessConfiguration, Configuration::Torrent)
site.run
