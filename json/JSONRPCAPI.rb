require 'user-api/UserAPI'

#this is used to pass any argument type to the generateNotification function - otherwise it would be limited to, say, String
class JSONAnyType
end

class JSONRPCAPI
	attr_reader :requestHandlers
	
	class Error < Exception
	end
	
	def initialize(configuration, connections, user)
		@api = UserAPI.new(configuration, connections, user)
		initialiseHandlers
	end
	
	def getLocalHandlers
		{
			#just for testing purposes
			sum: [Fixnum, Fixnum],
			
			#download
			downloadTorrentById: [String, Fixnum],
			
			#general
			getSiteStatistics: [String],
			
			#search
			search: [String],
			regexSearch: [String],
			
			#rtorrent
			getTorrents: [],
			
			#notifications
			getNotifications: [Fixnum, Fixnum],
		}
	end
	
	def getAPIHandlers
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
			
			#rtorrent
			getInfoHashes: [],
			getTorrentName: [String],
			getTorrentDownloadSpeed: [String],
			getTorrentUploadSpeed: [String],
			getTorrentFileCount: [String],
			getTorrentSize: [String],
			getTorrentBytesDone: [String],
			
			#notifications
			getNotificationCount: []
		}
	end
	
	def initialiseHandlers
		@localHandlers = getLocalHandlers
		
		@apiHandlers = getAPIHandlers
		
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
		case type.class
		when Array
			return false if input.class != type.class
			arrayType = type[0]
			input.each do |element|
				return false if !typeCheck(element, arrayType)
			end
		when Hash
			return false if input.class != type.class
			keyType, valueType = type.each_pair.first
			input.each do |key, value|
				return false if
					!typeCheck(key, keyType) ||
					!typeCheck(value, valueType)
			end
		when JSONAnyType
			return true
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
		
		if arguments.class != Array
			error("Invalid parameter type: #{arguments.class}")
		end
		
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
	
	def performSearch(target, isRegex)
		results = @api.search(target, isRegex)
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
	
	def search(target)
		return performSearch(target, false)
	end
	
	def regexSearch(target)
		return performSearch(target, true)
	end
	
	def getTorrents
		torrents = @api.getTorrents.map{|x| x.serialise}
		return torrents
	end
	
	def getNotifications(first, last)
		notifications = @api.getNotifications(first, last).map{|x| x.serialise}
		return notifications
	end
end
