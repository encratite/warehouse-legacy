require 'json'
require 'nil/ipc'
require 'notification-server/NotificationProtocol'

class NotificationProtocolClient
	def initialize(path)
		@path = path
		@client = nil
	end
	
	def notify(username, type, content)
		if @client == nil
			@client = Nil::IPCClient.new(@path)
		end
		return @client.notify(username, type, JSON.unparse(content))
	end
end
