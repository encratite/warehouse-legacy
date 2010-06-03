require 'json'

require 'json/JSONRPCHTTPRequest'
require 'json/JSONRPCAPI'

require 'shared/OutputHandler'
require 'shared/ConnectionContainer'
require 'shared/User'

require 'www-library/RequestManager'
require 'www-library/RequestHandler'
require 'www-library/HTTPReply'

require 'user-api/UserAPI'

require 'xmlrpc/client'

class JSONRPCHTTPServer
	WarehousePath = 'warehouse'
	
	def initialize(log)
		@output = OutputHandler.new(log)
		
		@connections = ConnectionContainer.new
		@database = @connections.sqlDatabase
		@configuration = configuration
		initialiseRequestManager
	end
	
	def initialiseRequestManager
		@requestManager = RequestManager.new(JSONRPCHTTPRequest)
		
		indexHandler = RequestHandler.new(nil)
		indexHandler.setHandler(method(:indexHandler))
		@requestManager.addHandler(indexHandler)
		
		warehouseHandler = RequestHandler.new(WarehousePath)
		warehouseHandler.setHandler(method(:warehouseHandler))
		@requestManager.addHandler(warehouseHandler)
		
		@requestManager.exceptionMessageHandler = method(:exceptionMessageHandler)
	end
	
	def output(request, line)
		@output.output("#{request.address}: #{line}")
	end
	
	def exceptionMessageHandler(message)
		@output.output("Exception: #{message}")
	end
	
	def processRequest(environment)
		@requestManager.handleRequest(environment)
	end
	
	def getUser(request)
		dataset = @database[:user_data]
		results = dataset.where(name: request.name).all
		if results.size != 1
			raise "Unable to find user #{request.name} in database"
		end
		userData = results[0]
		user = User.new(userData)
		return user
	end
	
	def error(message, id)
		reply =
		{
			'error' => message,
			'id' => id
		}
		
		return reply
	end
	
	def indexHandler(request)
		user = getUser(request)
		jsonApi = JSONRPCAPI.new(@configuration, @database, user)
		output(request, "Index request from user #{user.name} from #{request.address}")
		content = "Methods available on /#{WarehousePath}:\n\n"
		jsonApi.requestHandlers.each do |name, value|
			method, arguments = value
			content.concat "#{name}: #{arguments.inspect}\n"
		end
		reply = HTTPReply.new(content)
		reply.contentType = MIMEType::Plain
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
	
	def warehouseHandler(request)
		user = getUser(request)
		jsonApi = JSONRPCAPI.new(@configuration, @connections, user)
		replies = []
		request.jsonRequests.each do |jsonRequest|
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
		reply = HTTPReply.new(content)
		reply.contentType = 'application/json-rpc'
		return reply
	end
end
