require 'sequel'

require 'shared/User'

class QueueHandler
	def initialize(database)
		@database = database
		@queue = @database[:download_queue]
		@queueUser = @database[:download_queue_user]
	end
	
	def getQueueEntryUsers(name)
		result = @queue.where(name: name).select(:id).all
		return nil if result.empty?
		id = result.first[:id]
		results = @queueUser.join(:user_data, :id => :user_id)
		results = results.where(download_queue_user__queue_id: id)
		
		selection =
		[
			:id, :name, :is_administrator
		].map do |x|
			('user_data__' + x.to_s).to_sym.as(x)
		end
		
		results = results.select(*selection)
		users = results.map{|x| User.new(x)}
		return users
	end
	
	def insertQueueEntry(releaseData, torrent, userIds)
		queueData =
		{
			site: releaseData.site,
			site_id: releaseData.siteId,
			name: releaseData.name,
			torrent: torrent,
			release_size: releaseData.size,
			is_manual: releaseData.isManual,
			queue_time: Time.now.utc,
		}
		
		@database.transaction do
			queueId = @queue.insert(queueData)
			userIds.each do |id|
				queueUserData =
				{
					user_id: id,
					queue_id: queueId,
				}
				@queueUser.insert(queueUserData)
			end
		end
	end
	
	def removeOldQueueEntries(maximumAge)
		limit = (Time.now - maximumAge).to_i.to_s.lit
		@queue.filter{|x| x.queue_time <= limit}.delete
	end
	
	def removeQueueEntry(torrent)
		@queue.where(torrent: torrent).delete
	end
end
