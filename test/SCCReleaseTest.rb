$: << '.'

require 'nil/file'

require 'site/sceneaccess/SceneAccessSite'
require 'configuration/SceneAccess'
require 'configuration/SceneAccess'
require 'shared/ConnectionContainer'
require 'site/sceneaccess/SceneAccessReleaseData'

if ARGV.size != 1
  puts 'Invalid argument count'
  exit
end

id = ARGV[0]
path = "/details?id=#{id}"
puts "Getting #{id}"

site = SceneAccessSite.new(SceneAccessConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
output = site.httpHandler.get(path)
puts "Parsing..."
data = SceneAccessReleaseData.new(output)
puts data.name
