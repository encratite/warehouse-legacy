require 'user-api/UserAPI'

class JSONAPI
	attr_reader :requestHandlers
	
	def initialize(configuration, database, user)
		@api = UserAPI.new(configuration, database, user)
		initialiseHandlers
	end
	
	def initialiseHandlers
		@localHandlers =
		{
			#just for testing purposes
			sum: [Fixnum, Fixnum],
			
			#download
			downloadTorrentById: [String, Fixnum],
			
			#general
			getSiteStatistics: [String],
		}
		
		@apiHandlers =
		{
			#category
			assignCategoryToFilters: [String, [Fixnum]],
			deleteCategory: [String],

			#download
			downloadTorrentByName: [String],
			
			#filters
			convertFilterIndices: [[Fixnum]],
			addFilter: [String, String],
			listFilters: [],
			deleteFilters: [[Fixnum]],
			clearFilters: [],
			
			#general
			getFreeSpace: [],
			getBytesTransferred: [],
			#not secure right now - need to resolve process user issues first
			#deleteTorrent: [String],
			isAdministrator: [],
			getReleaseSizeLimit: [],
			getSearchResultCountMaximum: [],
			
			#search
			search: [],
		}
		
		@requestHandlers = {}
		
		processHandlers(@localHandlers, method(:method))
		processHandlers(@apiHandlers, @api.method(:method))
	end
	
	def processHandlers(input, handler)
		input.each do |symbol, arguments|
			@requestHandlers[symbol.to_s] = [handler.call(symbol), arguments]
		end
	end
	
	def typeCheck(input, type)
		return false if input.class != type
		if type == Array
			arrayType = type[0]
			input.each do |element|
				return false if !typeCheck(element, arrayType)
			end
		elsif type == Hash
			keyType, valueType = type.each_pair.first
			input.each do |key, value|
				return false if
					!typeCheck(key, keyType) ||
					!typeCheck(value, valueType)
			end
		end
		return true
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
			if !typeCheck(argument, argumentType)
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
	
	def downloadTorrentById(site, id)
		site = @api.getSiteByName(site)
		return @api.downloadTorrentById(site, id)
	end
	
	def getSiteStatistics(site)
		site = @api.getSiteByName(site)
		return @api.getSiteStatistics(site)
	end
end
