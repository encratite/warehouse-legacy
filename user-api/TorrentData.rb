require 'json/JSONObject'

class TorrentData < JSONObject
	attr_reader :infoHash, :name, :downloadSpeed, :uploadSpeed, :fileCount, :size, :bytesDone
	
	def initialize(infoHash, api)
		super()
		@infoHash = infoHash
		@name = api.getTorrentName(infoHash)
		@downloadSpeed = api.getTorrentDownloadSpeed(infoHash)
		@uploadSpeed = api.getTorrentUploadSpeed(infoHash)
		@fileCount = api.getTorrentFileCount(infoHash)
		@size = api.getTorrentSize(infoHash)
		@bytesDone = api.getTorrentBytesDone(infoHash)
	end
end
