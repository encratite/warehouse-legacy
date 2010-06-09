require 'json/JSONObject'

require 'shared/torrent'

class NotificationReleaseData < JSONObject
	#required for self.fromTable/Categoriser usage
	attr_accessor :id
	
	attr_reader :site, :siteId, :name, :time, :size, :isManual
	
	def initialize(site, siteId, name, size, isManual)
		super([:@id])
		@site = site
		@siteId = siteId
		@name = name
		@time = Time.now.utc
		@size = size
		@isManual = isManual
	end
	
	def self.fromTable(release, database)
		torrent = Torrent.getTorrentName(release)
		result = database[:download_queue].where(torrent: torrent).all
		if result.empty?
			output "Error: Unable to find a queue entry for release #{release}"
			return
		end
		queueData = result.first
		releaseData = NotificationReleaseData.new(
			queueData[:site],
			queueData[:site_id],
			queueData[:name],
			queueData[:size],
			queueData[:is_manual]
		)
		#for the Categoriser
		@id = queueData[:id]
		return releaseData
	end
end
