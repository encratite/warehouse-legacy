require 'nil/file'

require 'site/sceneaccess/SceneAccessSite'
require 'configuration/SceneAccess'
require 'configuration/Configuration'
require 'shared/ConnectionContainer'

site = SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)

lines = Nil.readLines('test/input/sceneaccess.log')
lines.each do |line|
	site.ircHandler.irc.processLine(line)
end
