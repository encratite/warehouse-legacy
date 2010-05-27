require 'json/JSONObject'

class TorrentData < JSONObject
	attr_reader :infoHash, :name, :downloadSpeed, :uploadSpeed, :fileCount, :size, :bytesDone
	
	def initialize(infoHash, name, downloadSpeed, uploadSpeed, fileCount, size, bytesDone)
		super()
		@infoHash = infoHash
		@name = name
		@downloadSpeed = downloadSpeed
		@uploadSpeed = uploadSpeed
		@fileCount = fileCount
		@size = size
		@bytesDone = bytesDone
	end
end
