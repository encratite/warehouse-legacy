require 'user-api/TorrentData'

require 'xmlrpc/client'

require 'shared/Timer'

class UserAPI
	#this returns an array of the hashes (strings) associated with the torrents in rtorrent
	def getInfoHashes
		return @rpc.call('download_list')
	end
	
	def getTorrentName(infoHash)
		return @rpc.call('d.get_name', infoHash)
	end
	
	#returns the download speed in bytes per second
	def getTorrentDownloadSpeed(infoHash)
		return @rpc.call('d.get_down_rate', infoHash)
	end
	
	#returns the upload speed in bytes per second
	def getTorrentUploadSpeed(infoHash)
		return @rpc.call('d.get_up_rate', infoHash)
	end
	
	#returns the number of files associated with the torrent
	def getTorrentFileCount(infoHash)
		return @rpc.call('d.get_size_files', infoHash)
	end
	
	#returns the size of a torrent download in bytes
	def getTorrentSize(infoHash)
		return @rpc.call('d.get_size_bytes', infoHash)
	end
	
	#returns the number of bytes of a torrent which have been downloaded successfully so far
	def getTorrentBytesDone(infoHash)
		return @rpc.call('d.get_bytes_done', infoHash)
	end
	
	#at the request of death
	def getTorrents
		timer = Timer.new
		infoHashes = getInfoHashes
		puts "Got #{infoHashes.size} hashes"
		callData = []
		infoHashes.each do |infoHash|
			callData.concat [
				['d.get_name', infoHash],
				['d.get_down_rate', infoHash],
				['d.get_up_rate', infoHash],
				['d.get_size_files', infoHash],
				['d.get_size_bytes', infoHash],
				['d.get_bytes_done', infoHash]
			]
		end
		puts 'Performing multicall...'
		
		rpcData = @rpc.multicall(callData)
		offset = 0
		callCountPerTorrent = 6
		output = []
		infoHashes.each do |infoHash|
			data = [infoHash] + rpcData[offset..(offset + callCountPerTorrent - 1)]
			torrent = TorrentData.new(*data)
			output << torrent
			offset += callCountPerTorrent
		end
		
		delay = timer.stop
		puts "Finished processing multicall, execution took #{delay} ms"
		
		return output
	end
end
