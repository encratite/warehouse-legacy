$: << '.'

require 'site/sceneaccess/SceneAccessSite'
require 'configuration/SceneAccess'
require 'configuration/Configuration'
require 'shared/ConnectionContainer'

site = SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
site.run
