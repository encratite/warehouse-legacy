require 'json'

require 'json/JSONRPCHTTPRequest'
require 'json/JSONRPCAPI'

require 'shared/OutputHandler'
require 'shared/User'

require 'user-api/UserAPI'

require 'xmlrpc/client'

class JSONRPCHandler
	def initialize(configuration, connections, outputHandler, apiClass = JSONRPCAPI)
		@output = outputHandler
		
		@connections = connections
		@database = connections.sqlDatabase
		@configuration = configuration
		@apiClass = apiClass
	end
	
	def output(request, line)
		@output.output("#{request.address}: #{line}")
	end
	
	def exceptionMessageHandler(message)
		@output.output("Exception: #{message}")
	end
	
	def error(message, id)
		reply =
		{
			'error' => message,
			'id' => id
		}
		
		return reply
	end

	def outputData(type, user, message)
		output(request, "#{type} from user #{user.name} from #{user.address}: #{message}")
		return
	end
	
	def outputError(type, user, message, id, replies)
		outputData(type, user, message)
		replies << error(message, id)
		return
	end
	
	#these two functions take a user which has the address field set
	def processRPCRequests(user, requests)
		jsonAPI = @apiClass.new(@configuration, @connections, user)
		return processRPCRequestsByAPI(user, requests, jsonAPI)
	end
	
	def processRPCError(error, user, id, replies)
		messages =
		{
			JSONRPCAPI::Error => 'JSON-RPC API exception',
			UserAPI::Error => 'User API exception',
			XMLRPC::FaultException => 'XML RPC exception',
			RuntimeError => 'Runtime error',
			Errno::ECONNREFUSED => ['Connection error', "The server refused the connection (the HTTP proxy for the XML RPC interface probably isn't running)"]
		}
		
		messageData = messages[error.class]
		raise error if messageData == nil
		if messageData.class == Array
			type, message = messageData
		else
			type = messageData
			message = error.message
		end
		outputError(type, user, message, id, replies)
	end
	
	def processRPCRequestsByAPI(user, requests, jsonAPI)
		replies = []
		requests.each do |jsonRequest|
			string = nil
			id = jsonRequest['id']
			if id == nil
				errorMessage = 'Missing ID in call'
				outputData(errorMessage, user, request, jsonRequest.inspect)
				content = errorMessage
			end
			begin
				outputData('JSON-RPC call', user, request, jsonRequest.inspect)
				reply = jsonAPI.processJSONRPCRequest(jsonRequest)
				replies << reply
			rescue => error
				processRPCError(error, user, id, replies)
			end
		end
		if request.isMultiCall
			jsonOutput = replies
		else
			jsonOutput = replies[0]
		end
		content = JSON.unparse(jsonOutput)
		return content
	end
end
