require 'nil/ipc'
require 'notification/NotificationProtocol'

class NotificationProtocolClient
	attr_writer :throwOnError
	
	def initialize(path)
		@path = path
		@client = nil
		@throwOnError = false
	end
	
	def notify(target, type, content, isRetry = false)
		begin
			if @client == nil
				@client = Nil::IPCClient.new(@path)
			end
			return @client.notify(target, type, content)
		rescue Nil::IPCError => message
			@client = nil
			if isRetry
				if @throwOnError
					raise message
				else
					puts "Unable to connect to IPC server to deliver notification: #{message}"
				end
			else
				#retry once before throwing
				notify(target, type, content, true)
			end
		end
		
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
