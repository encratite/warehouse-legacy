require 'json'

module NotificationProtocol
	def self.createUnit(type, data)
		unit =
		{
			'type' => type,
			'data' => data
		}
		
		return unit
	end
	
	def self.notification(type, content)
		data =
		{
			#UNIX timestamp
			'time' => Time.now.utc.to_i,
			'type' => type,
			'content' => content
		}
		return data
	end
	
	def self.notificationUnit(type, content)		
		data = self.notification(type, content)
		output = self.createUnit('notification', data)
		return output
	end
end
