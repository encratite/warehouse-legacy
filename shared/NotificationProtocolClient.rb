require 'nil/ipc'
require 'notification/NotificationProtocol'

class NotificationProtocolClient
	def initialize(path)
		@path = path
		@client = nil
	end
	
	def notify(target, type, content)
		if @client == nil
			@client = Nil::IPCClient.create(@path)
			if @client == nil
				#this should probably get some proper logging etc
				puts "Unable to create IPC client on socket #{path}"
				return nil
			end
		end
		return @client.notify(target, type, content)
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
