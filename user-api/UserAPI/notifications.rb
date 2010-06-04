require 'user-api/NotificationData'

class UserAPI
	#needs to be serialised in the JSON RPC API
	def getNewNotifications
		@database.transaction do
			notifications = @database[:user_notification].select(:notification_time, :notification_type, :content)
			notifications = notifications.where(user_id: @user.id).filter{|x| x >= @user.lastNotification}.all
			newTime = Time.now.utc
			@user.lastNotification = newTime
			#update the time of the last notification for this user to the current timestamp
			#this will no longer return the current new notifications when this function is called again
			@database[:user_data].where(id: @user.id).update(last_notification: newTime)
			notifications = notifications.map do |notification|
				NotificationData.new(notification)
			end
			return notifications
		end
	end
	
	def getNotificationCount
		return @database[:user_notification].where(user_id: @user.id).count
	end
	
	def getOldNotifications(first, last)
	end
	
	def generateNotification(notification)
	end
end
