$: << '.'

require 'nil/file'

require 'site/torrentvault/TorrentVaultSite'
require 'configuration/TorrentVault'
require 'configuration/Configuration'
require 'shared/ConnectionContainer'
require 'site/torrentvault/TorrentVaultReleaseData'

id = ARGV[0]

site = TorrentVaultSite.new(TorrentVaultConfiguration, Configuration::Torrent, ConnectionContainer.new, Configuration)
output = site.httpHandler.get("/torrents.php?id=#{id}")
puts "Parsing..."
data = TorrentVaultReleaseData.new(output)
puts data.name
