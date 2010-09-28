class User
	attr_reader :id, :name, :isAdministrator
	attr_accessor :lastNotification
	
	#not always available I think - added for the JSON RPC stuff
	attr_accessor :address
	
	def initialize(*arguments)
		#overloaded constructor hack
		if arguments.size == 1
			data = arguments[0]
			@id = data[:id]
			@name = data[:name]
			@isAdministrator = data[:is_administrator]
		else
			@id, @name, @isAdministrator = arguments
		end
	end
	
	def ==(other)
		if other.class == String
			return @name == other
		elsif other.class == Fixnum
			return @id == other
		elsif other == nil
			return false
		else
			raise 'Invalid user comparison'
		end
	end
	
	def !=(other)
		return !(self == other)
	end
end
