module Torrent
	TorrentExtension = '.torrent'
	
	def getTorrentBase(torrent)
		if !torrrent.end_with?(TorrentExtension)
			raise "Invalid torrent name: #{torrent}"
		end
		output = torrent[0..(torrent.size - TorrentExtension.size - 1)]
		return output
	end
	
	def getTorrentName(base)
		return base + TorrentExtension
	end
end
