require 'nil/file'

require_relative 'site/sceneaccess/SceneAccessSite'
require_relative 'configuration/SceneAccess'
require_relative 'configuration/Configuration'
require_relative 'shared/ConnectionContainer'

site = SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)

lines = Nil.readLines('test/input/sceneaccess.log')
lines.each do |line|
	site.ircHandler.irc.processLine(line)
end
