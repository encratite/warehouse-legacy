require 'json'
require 'nil/ipc'
require 'notifiation/NotificationProtocol'

class NotificationProtocolClient
	def initialize(path)
		@path = path
		@client = nil
	end
	
	def notify(target, type, content)
		if @client == nil
			@client = Nil::IPCClient.new(@path)
		end
		return @client.notify(target, type, JSON.unparse(content))
	end
	
	def queuedNotification(target, releaseData)
		notify(target, 'queued', releaseData.serialise)
	end
	
	def downloadedNotification(target, releaseData)
		notify(target, 'downloaded', releaseData.serialise)
	end
	
	def deletedNotification(target, releaseData)
		notify(target, 'downloadDeleted', releaseData.serialise)
	end
end
