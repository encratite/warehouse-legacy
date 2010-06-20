#the rest of the configuration is in TorrentPath.rb, Cleaner.rb, HTTP.rb

module Configuration
	module Torrent
		Gigabyte = 2**30
		SizeLimit = 25 * Gigabyte
		
		NIC = 'eth0'
	end
end
