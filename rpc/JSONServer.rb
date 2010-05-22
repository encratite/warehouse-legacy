require 'json'

require 'rpc/JSONRequest'

require 'shared/OutputHandler'
require 'shared/database'
require 'shared/User'

require 'www-library/RequestManager'

class JSONServer
	def initialize(sessionCookie, log)
		@sessionCookie = sessionCookie
		@output = OutputHandler.new(log)
		@database = getDatabase
		@requestManager = RequestManager.new
	end
	
	def output(request, line)
		@output.output("#{request.address}: #{line}")
	end
	
	def processRequest(environment)
		request = JSONRequest.new(environment)
		begin
			request.processJSON
		rescue JSON::ParserError => exception
			output(request, "JSON error: #{exception.message}")
			return
		end
		
		readSessionData(request)
	end
	
	def readSessionData(request)
		sessionString = request.cookies[@sessionCookie]
		return false if sessionString == nil
		sessions = @database[:user_session]
		results = sessions.join(:user_data, id: :user_id).where(ip: request.address, session_string: sessionString).filter(:id, :name, :is_administrator).all
		if results.empty?
			output "Received an invalid session string from #{request.address}: #{sessionString}"
			return false
		end
		result = results[0]
		request.user = User.new(result)
		output "Recognised the session string of user #{request.user.name}"
		return true
	end
end
