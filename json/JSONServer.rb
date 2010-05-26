require 'json'

require 'nil/file'

require 'json/JSONRequest'
require 'json/JSONAPI'

require 'shared/OutputHandler'
require 'shared/database'
require 'shared/User'

require 'www-library/RequestManager'
require 'www-library/RequestHandler'
require 'www-library/HTTPReply'

require 'user-api/UserAPI'

class JSONServer
	WarehousePath = 'warehouse'
	
	def initialize(configuration)
		log = Nil.joinPaths(configuration::Logging::Path, Configuration::RPCServer::Log)
		@sessionCookie = configuration::RPCServer::SessionCookie
		@output = OutputHandler.new(log)
		@database = getDatabase
		@configuration = configuration
		initialiseRequestManager
	end
	
	def initialiseRequestManager
		@requestManager = RequestManager.new(JSONRequest)
		
		indexHandler = RequestHandler.new(nil)
		indexHandler.setHandler(method(:indexHandler))
		@requestManager.addHandler(indexHandler)
		
		warehouseHandler = RequestHandler.new(WarehousePath)
		warehouseHandler.setHandler(method(:warehouseHandler))
		@requestManager.addHandler(warehouseHandler)
	end
	
	def output(request, line)
		@output.output("#{request.address}: #{line}")
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
		jsonApi = JSONAPI.new(@configuration, @database, user)
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
	
	def outputError(type, user, request, message)
		output(request, "#{type} from user #{user.name} from #{request.address}: #{message}")
	end
	
	def warehouseHandler(request)
		user = getUser(request)
		jsonApi = JSONAPI.new(@configuration, @database, user)
		content = ''
		request.jsonRequests.each do |jsonRequest|
			string = nil
			id = jsonRequest['id']
			begin
				outputError('JSON-RPC call', user, request, jsonRequest.inspect)
				reply = jsonApi.processJSONRPCRequest(jsonRequest)
				string = JSON.unparse(reply)
			rescue JSONAPI::Error => exception
				outputError('JSON-RPC API exception', user, request, exception.message)
				string = error(exception.message, id)
			rescue UserAPI::Error => exception
				outputError('User API exception', user, request, exception.message)
				string = error(exception.message, id)
			end
			content.concat("#{string}\n")
		end
		reply = HTTPReply.new(content)
		reply.contentType = 'application/json-rpc'
		return reply
	end
end
