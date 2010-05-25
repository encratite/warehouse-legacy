require 'user-api/UserAPI'

class JSONAPI
	def initialize(configuration, database, user)
		@api = UserAPI.new(configuration, database, user)
		initialiseHandlers
	end
	
	def initialiseHandlers
		@localHandlers =
		[
			#just for testing purposes
			[:sum, [Fixnum, Fixnum]],
		]
		
		@apiHandlers =
		[
			[:assignCategoryToFilters, [String, [Fixnum]]],
		]
		
		@requestHandlers = {}
		
		processHandlers(@localHandlers, method(:method))
		processHandlers(@apiHandlers, @api.method(:method))
	end
	
	def processHandlers(input, handler)
		input.each do |symbol, arguments|
			@requestHandlers[symbol.to_s] = [handler.call(symbol), arguments]
		end
	end
	
	def processJSONRPCRequest(jsonRequest)
		#{"id":1,"method":"system.about","params":[]}
		id = jsonRequest['id']
		method = jsonRequest['method']
		arguments = jsonRequest['params']
		
		handlerData = @requestHandlers[method]
		if handlerData == nil
			return error("The method \"#{method}\" does not exist", id)
		end
		
		handlerMethod = handlerData[0]
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
		
		
		result = handlerMethod.call(*arguments)
		
		reply =
		{
			'result' => result,
			'error' => nil,
			'id' => id
		}
		
		return reply
	end
	
	def sum(a, b)
		return a + b
	end
end
