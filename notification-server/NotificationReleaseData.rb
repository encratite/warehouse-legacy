require 'json/JSONObject'

class NotificationReleaseData < JSONObject
	def initialize(site, siteId, name, size, isManual)
		super()
		@site = site
		@siteId = siteId
		@name = name
		@time = Time.now
		@size = size
		@isManual = isManual
	end
end
