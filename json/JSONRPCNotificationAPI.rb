require_relative 'json/JSONRPCAPI'

#extended JSONRPCAPI which can generate notifications for the JSON RPC API available through the notification server
class JSONRPCNotificationAPI < JSONRPCAPI
	def initialize(configuration, connections, client)
		super(configuration, connections, client.user)
		@client = client
	end
	
	def getLocalHandlers
		output = super
		output[:generateNotification] = [String, String]
		return output
	end
	
	def generateNotification(type, content)
		@api.generateNotification(@client, type, content)
		return nil
	end
end
