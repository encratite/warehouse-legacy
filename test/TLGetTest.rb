$: << '.'

require 'nil/file'

require 'site/torrentleech/TorrentLeechSite'
require 'site/torrentleech/TorrentLeechReleaseData'

require 'configuration/TorrentLeech'
require 'configuration/TorrentLeech'
require 'shared/ConnectionContainer'

if ARGV.size != 1
  puts 'Invalid argument count'
  exit
end

path = ARGV[0]
puts "Getting #{path}"

site = TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
site.login
output = site.httpHandler.get(path)
puts output.inspect