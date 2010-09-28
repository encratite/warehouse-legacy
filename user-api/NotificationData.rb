require 'json'

require 'json/JSONObject'
require 'json/parse'

class NotificationData < JSONObject
	def initialize(input)
		super()
		@time = input[:notification_time]
		@type = input[:notification_type]
		@content = parseJSON(input[:content])
	end
end
