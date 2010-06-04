require 'json/JSONObject'

class NotificationData < JSONObject
	def initialize(input)
		super()
		@time = input[:notification_time]
		@type = input[:notification_type]
		@content = input[:content]
	end
end
