require 'user-api/UserAPI'

class JSONAPI
	attr_reader :requestHandlers
	
	class Error < Exception
	end
	
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
			
			#search
			search: [String],
			serialisableSearch: [String],
		}
		
		@apiHandlers =
		{
			#category
			assignCategoryToFilters: [String, [Fixnum]],
			deleteCategory: [String],

			#download
			downloadTorrentByName: [String],
			
			#filters
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
			getSiteNames: [],
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
		if type.class == Array
			return false if input.class != type.class
			arrayType = type[0]
			input.each do |element|
				return false if !typeCheck(element, arrayType)
			end
		elsif type.class == Hash
			return false if input.class != type.class
			keyType, valueType = type.each_pair.first
			input.each do |key, value|
				return false if
					!typeCheck(key, keyType) ||
					!typeCheck(value, valueType)
			end
		else
			return false if input.class != type
		end
		return true
	end
	
	def error(message)
		raise Error.new(message)
	end
	
	def processJSONRPCRequest(jsonRequest)
		#{"id":1,"method":"system.about","params":[]}
		id = jsonRequest['id']
		method = jsonRequest['method']
		arguments = jsonRequest['params']
		
		handlerData = @requestHandlers[method]
		if handlerData == nil
			error("The method \"#{method}\" does not exist")
		end
		
		handlerMethod = handlerData[0]
		handlerArguments = handlerData[1]
		if arguments.size != handlerArguments.size
			error("The argument counts for the method \"#{method}\" mismatch (expected: #{handlerArguments.size}, given: #{arguments.size})")
		end
		
		offset = 0
		while offset < arguments.size
			argument = arguments[offset]
			argumentType = handlerArguments[offset]
			if !typeCheck(argument, argumentType)
				error("The argument type of argument #{offset + 1} for method \"#{method}\" is invalid (expected: #{argumentType}, given: #{argument.class})")
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
	
	def downloadTorrentById(siteName, id)
		site = @api.getSiteByName(siteName)
		return @api.downloadTorrentById(site, id)
	end
	
	def getSiteStatistics(siteName)
		site = @api.getSiteByName(siteName)
		return @api.getSiteStatistics(site).serialise
	end
	
	def search(target)
		results = @api.search(target)
		serialisedResults = {}
		results.each do |key, values|
			serialisedResults[key] = values.map{|x| x.serialise}
		end
		return serialisedResults
	end
	
	def serialisableSearch(target)
		results = @api.search(target)
		serialisedResults = []
		results.each do |key, values|
			serialisedResult =
			{
				'site' => key,
				'results' => values.map{|x| x.serialise}
			}
			serialisedResults << serialisedResult
		end
		return serialisedResults
	end
end
