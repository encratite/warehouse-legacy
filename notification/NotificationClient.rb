require 'openssl'
require 'json'

require 'nil/communication'

require 'shared/ssl'

class NotificationClient < Nil::SerialisedCommunication
	attr_reader :socket
	
	def initialize(socket, user)
		super(socket, JSON::ParserError)
		@user = user
		@sendMutex = Mutex.new
	end
	
	def serialiseData(input)
		return JSON.unparse(input)
	end
	
	def deserialiseData(input)
		return JSON.parse(input)
	end
	
	def sendData(input)
		#use a mutex - I am not sure if the TCP sending stuff is thread safe
		@sendMutex.synchronize { super(input) }
	end
end
