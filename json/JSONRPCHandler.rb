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
		@output.output("#{type} from user #{user.name} from #{user.address}: #{message}")
		return
	end
	
	def outputError(type, user, message, id, replies)
		outputData(type, user, message)
		replies << error(message, id)
		return
	end
	
	#processRPCRequests and processRPCRequestsByAPI take a user which has the address field set
	#input may be either a single request or an array of requests
	def processRPCRequests(user, input)
		jsonAPI = @apiClass.new(@configuration, @connections, user)
		return processRPCRequestsByAPI(user, input, jsonAPI)
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
	
	def processRPCRequestsByAPI(user, input, jsonAPI)
		isMultiCall = input.class == Array
		if isMultiCall
			requests = input
		else
			requests = [input]
		end
		replies = []
		requests.each do |jsonRequest|
			string = nil
			id = jsonRequest['id']
			if id == nil
				errorMessage = 'Missing ID in call'
				outputData(errorMessage, user, jsonRequest.inspect)
				#not sure how to handle this properly - terminate connection with some error message?
				replies << nil
			end
			begin
				outputData('JSON-RPC call', user, jsonRequest.inspect)
				reply = jsonAPI.processJSONRPCRequest(jsonRequest)
				replies << reply
			rescue JSONRPCAPI::Error => error
				processRPCError(error, user, id, replies)
			rescue => error
				processRPCError(error, user, id, replies)
			end
		end
		if isMultiCall
			jsonOutput = replies
		else
			jsonOutput = replies[0]
		end
		return jsonOutput
	end
end
