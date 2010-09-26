require 'json'

require_relative 'json/JSONObject'

class NotificationData < JSONObject
	def initialize(input)
		super()
		@time = input[:notification_time].utc
		@type = input[:notification_type]
		@content = JSON::parse(input[:content])
	end
end
