$: << '.'

require 'nil/file'

require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'
require 'configuration/Configuration'
require 'shared/ConnectionContainer'
require 'site/torrentvault/TorrentVaultReleaseData'

id = ARGV[0]

puts 'Creating the site object'
site = TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
puts 'Retrieving the data'
output = site.httpHandler.get("/torrents.php?id=#{id}")
puts 'Parsing the data'
data = TorrentVaultReleaseData.new(output)
puts "Name: #{data.name}"
puts data.inspect
