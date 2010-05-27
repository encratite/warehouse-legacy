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
		
		#puts "Got #{infoHashes.size} hashes after #{timer.stop} ms"
		
		callData = []
		infoHashes.each do |infoHash|
			callData.concat [
				['d.get_name', infoHash],
				['d.get_down_rate', infoHash],
				['d.get_up_rate', infoHash],
				['d.get_size_files', infoHash],
				['d.get_size_bytes', infoHash],
				['d.get_bytes_done', infoHash],
				['d.get_tied_to_file', infoHash],
			]
		end
		
		#puts "Created multicall arguments in #{timer.stop} ms"
		
		rpcData = @rpc.multicall(*callData)
		
		#puts "The multicall itself took #{timer.stop} ms"
		
		offset = 0
		callCountPerTorrent = 7
		output = []
		infoHashes.each do |infoHash|
			data = [infoHash] + rpcData[offset..(offset + callCountPerTorrent - 1)]
			torrent = TorrentData.new(*data)
			output << torrent
			offset += callCountPerTorrent
		end
		
		#puts "Finished processing the RPC data after #{timer.stop} ms"
		
		return output
	end
end
