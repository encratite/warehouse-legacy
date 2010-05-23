require 'json'

require 'rpc/JSONRequest'

require 'shared/OutputHandler'
require 'shared/database'
require 'shared/User'

require 'www-library/RequestManager'
require 'www-library/RequestHandler'
require 'www-library/HTTPReply'

class JSONServer
	RequestHandlers =
	{
		'sum' => [:sumRPC, [Fixnum, Fixnum]],
		'login' => [:loginRPC, [String, String]],
	}
	
	def initialize(sessionCookie, log)
		@sessionCookie = sessionCookie
		@output = OutputHandler.new(log)
		@database = getDatabase
		initialiseRequestManager
	end
	
	def initialiseRequestManager
		@requestManager = RequestManager.new(JSONRequest)
		mainHandler = RequestHandler.new(nil)
		mainHandler.setHandler(method(:indexHandler))
		@requestManager.addHandler(mainHandler)
	end
	
	def output(request, line)
		@output.output("#{request.address}: #{line}")
	end
	
	def processRequest(environment)
		@requestManager.handleRequest(environment)
	end
	
	def getUser(request)
		sessionString = request.cookies[@sessionCookie]
		return nil if sessionString == nil
		sessions = @database[:user_session]
		results = sessions.join(:user_data, id: :user_id).where(ip: request.address, session_string: sessionString).filter(:id, :name, :is_administrator).all
		if results.empty?
			output(request, "Received an invalid session string: #{sessionString}")
			return nil
		end
		result = results[0]
		user = User.new(result)
		output(request, "Recognised the session string of user #{user.name}")
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
		user = getUser(request)
		content = ''
		userDescription = user == nil ? '' : " (#{user})"
		request.jsonRequests.each do |jsonRequest|
			output(request, "JSON-RPC call from #{request.address}#{userDescription}: #{jsonRequest.inspect}")
			content.concat(JSON.unparse(processJSONRPCRequest(jsonRequest, user)) + "\n")
		end
		reply = HTTPReply.new(content)
		reply.contentType = 'application/json-rpc'
		return reply
	end
	
	def sumRPC(a, b)
		return a + b
	end
	
	def loginRPC(username, password)
		return nil
	end
end
