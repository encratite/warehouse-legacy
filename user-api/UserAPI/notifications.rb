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
	
	#internal use only
	def getUserNotifications
		notifications = @database[:user_notification].where(user_id: @user.id)
		return convertNotifications(notifications)
	end
	
	def getNotificationCount
		return getUserNotifications.count
	end
	
	#needs to be serialised in the JSON RPC API
	def getNotifications(offset, count)
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
