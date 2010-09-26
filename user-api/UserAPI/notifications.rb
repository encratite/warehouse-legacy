require 'sequel'

require 'user-api/NotificationData'
require 'notification/NotificationProtocol'

class UserAPI
	#internal use only
	def convertNotifications(input)
		output = input.map do |notification|
			NotificationData.new(notification)
		end
		return output
	end
	
	#needs to be serialised in the JSON RPC API
	def getNewNotifications
		@database.transaction do
			notifications = @database[:user_notification].select(:notification_time, :notification_type, :content)
			notifications = notifications.where(user_id: @user.id).filter{|x| x.notification_time > @user.lastNotification}.all
			newTime = Time.now.utc
			@user.lastNotification = newTime
			#update the time of the last notification for this user to the current timestamp
			#this will no longer return the current new notifications when this function is called again
			@database[:user_data].where(id: @user.id).update(last_notification: newTime)
			return convertNotifications(notifications)
		end
	end
	
	#internal use only
	def getUserNotifications
		notifications = @database[:user_notification].where(user_id: @user.id)
		return convertNotifications(notifications)
	end
	
	def getNotificationCount
		return getUserNotifications.count
	end
	
	#needs to be serialised in the JSON RPC API
	def getOldNotifications(offset, count)
		begin
			notifications = @database[:user_notification].where(user_id: @user.id).reverse_order(:notification_time).limit(count, offset).all
			return convertNotifications(notifications)
		rescue Sequel::Error
			error "Invalid offset/count arguments: #{offset}, #{count}"
		end
	end
	
	#cannot be used directly either - requires a local function
	def generateNotification(client, type, content)
		unit = NotificationProtocol.notificationUnit(type, content)
		client.sendData(unit)
	end
end
