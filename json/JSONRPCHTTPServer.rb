require 'json/JSONRPCHandler'

require 'www-library/RequestManager'
require 'www-library/RequestHandler'
require 'www-library/HTTPReply'

class JSONRPCHTTPServer < JSONRPCHandler
	WarehousePath = 'warehouse'
	
	def initialize(configuration, connections, log)
		output = OutputHandler.new(log)
		super(configuration, connections, output)
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
	
	def processRequest(environment)
		@requestManager.handleRequest(environment)
	end
	
	def getUser(request)
		dataset = @database[:user_data]
		results = dataset.where(name: request.name).all
		if results.empty?
			raise "Unable to find user #{request.name} in database"
		end
		userData = results.first
		user = User.new(userData)
		return user
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
	
	def warehouseHandler(request)
		user = getUser(request)
		user.address = request.address
		content = processRPCRequests(user, request.jsonInput)
		reply = HTTPReply.new(content)
		reply.contentType = 'application/json-rpc'
		return reply
	end
end
