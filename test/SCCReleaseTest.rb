$: << '.'

require 'nil/file'

require 'site/sceneaccess/SceneAccessSite'
require 'configuration/SceneAccess'
require 'configuration/SceneAccess'
require 'shared/ConnectionContainer'
require 'site/sceneaccess/SceneAccessReleaseData'

id = ARGV[0]

site = SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
output = site.httpHandler.get("/torrents.php?id=#{id}")
puts "Parsing..."
data = SceneAccessReleaseData.new(output)
puts data.name
