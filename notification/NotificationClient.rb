require 'openssl'
require 'json'

require 'nil/communication'

require 'shared/ssl'

require 'json/parse'

class NotificationClient < Nil::SerialisedCommunication
	attr_reader :socket, :user
	
	def initialize(socket, user)
		super(socket, JSON::ParserError)
		@user = user
		@sendMutex = Mutex.new
	end
	
	def serialiseData(input)
		return input.to_json
	end
	
	def deserialiseData(input)
		return parseJSON(input)
	end
	
	def sendData(input)
		#use a mutex - I am not sure if the TCP sending stuff is thread safe
		@sendMutex.synchronize { super(input) }
	end
end
