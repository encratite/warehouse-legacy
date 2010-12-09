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

id = ARGV[0]
path = "/torrent/#{id}"
puts "Getting #{id}"

site = TorrentLeechSite.new(TorrentLeechConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
output = site.httpHandler.get(path)
#puts output
puts "Parsing..."
data = TorrentLeechReleaseData.new(output)
puts data.inspect
