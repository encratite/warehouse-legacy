require 'json/JSONObject'

class TorrentData < JSONObject
	attr_reader :infoHash, :name, :downloadSpeed, :uploadSpeed, :fileCount, :size, :bytesDone, :torrentPath
	
	def initialize(infoHash, name, downloadSpeed, uploadSpeed, fileCount, size, bytesDone, torrentPath)
		super()
		@infoHash = infoHash
		@name = name
		@downloadSpeed = downloadSpeed
		@uploadSpeed = uploadSpeed
		@fileCount = fileCount
		@size = size
		@bytesDone = bytesDone
		@torrentPath = torrentPath
	end
end
