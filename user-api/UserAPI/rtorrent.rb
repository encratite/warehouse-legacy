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
end
