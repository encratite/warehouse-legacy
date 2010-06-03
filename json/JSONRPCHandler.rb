require 'json'

require 'json/JSONRPCHTTPRequest'
require 'json/JSONRPCAPI'

require 'shared/OutputHandler'
require 'shared/User'

require 'user-api/UserAPI'

require 'xmlrpc/client'

class JSONRPCHandler
	def initialize(connections, outputHandler)
		@output = outputHandler
		
		@connections = connections
		@database = @connections.sqlDatabase
		@configuration = configuration
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

	def outputData(type, user, request, message)
		output(request, "#{type} from user #{user.name} from #{request.address}: #{message}")
		return
	end
	
	def outputError(type, user, request, message, id, replies)
		outputData(type, user, request, message)
		replies << error(message, id)
		return
	end
	
	def processRPCRequests(user, requests)
		jsonApi = JSONRPCAPI.new(@configuration, @connections, user)
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
				reply = jsonApi.processJSONRPCRequest(jsonRequest)
				replies << reply
			rescue JSONRPCAPI::Error => exception
				outputError('JSON-RPC API exception', user, request, exception.message, id, replies)
			rescue UserAPI::Error => exception
				outputError('User API exception', user, request, exception.message, id, replies)
			rescue XMLRPC::FaultException => exception
				outputError('XML RPC exception', user, request, exception.message, id, replies)
			rescue RuntimeError => exception
				outputError('Runtime error', user, request, exception.message, id, replies)
			rescue Errno::ECONNREFUSED
				outputError('Connection error', user, request, "The server refused the connection (the HTTP proxy for the XML RPC interface probably isn't running)", id, replies)
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
