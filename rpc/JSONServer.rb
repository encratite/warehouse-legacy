require 'json'

require 'nil/file'

require 'rpc/JSONRequest'

require 'shared/OutputHandler'
require 'shared/database'
require 'shared/User'

require 'www-library/RequestManager'
require 'www-library/RequestHandler'
require 'www-library/HTTPReply'

require 'user-api/UserAPI'

class JSONServer
	WarehousePath = 'warehouse'
	
	RequestHandlers =
	{
		#just for testing purposes
		'sum' => [:sumRPC, [Fixnum, Fixnum]],
	}
	
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
		user = User.new(results[0])
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
	
	def processJSONRPCRequest(jsonRequest, user)
		#{"id":1,"method":"system.about","params":[]}
		id = jsonRequest['id']
		method = jsonRequest['method']
		arguments = jsonRequest['params']
		
		handlerData = RequestHandlers[method]
		if handlerData == nil
			return error("The method \"#{method}\" does not exist", id)
		end
		
		handlerMethod = method(handlerData[0])
		handlerArguments = handlerData[1]
		if arguments.size != handlerArguments.size
			return error("The argument counts for the method \"#{method}\" mismatch (expected: #{handlerArguments.size}, given: #{arguments.size})", id)
		end
		
		offset = 0
		while offset < arguments.size
			argument = arguments[offset]
			argumentType = handlerArguments[offset]
			if !(argumentType === argument)
				return error("The argument type of argument #{offset + 1} for method \"#{method}\" is invalid (expected: #{argumentType}, given: #{argument.class})", id)
			end
			offset += 1
		end
		
		begin
			arguments = [user] + arguments
			result = handlerMethod.call(*arguments)
			
			reply =
			{
				'result' => result,
				'error' => nil,
				'id' => id
			}
			
			return reply
		rescue RuntimeError => exception
			return error(exception.message, id)
		end
	end
	
	def indexHandler(request)
		content = "Methods available on /#{WarehousePath}:\n\n"
		RequestHandlers.each do |key, value|
			symbol, arguments = value
			content.concat "#{key}: #{arguments.inspect}\n"
		end
		reply = HTTPReply.new(content)
		reply.contentType = MIMEType::Plain
		return reply
	end
	
	def warehouseHandler(request)
		user = getUser(request)
		api = UserAPI.new(@configuration, @database, user)
		content = ''
		request.jsonRequests.each do |jsonRequest|
			output(request, "JSON-RPC call from user #{user.name} from #{request.address}: #{jsonRequest.inspect}")
			content.concat(JSON.unparse(processJSONRPCRequest(jsonRequest, user)) + "\n")
		end
		reply = HTTPReply.new(content)
		reply.contentType = 'application/json-rpc'
		return reply
	end
	
	def sumRPC(a, b)
		return a + b
	end
end
