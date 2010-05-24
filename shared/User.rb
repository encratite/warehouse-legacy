class User
	attr_reader :id, :name, :isAdministrator
	
	def initialize(*arguments)
		#overloaded constructor hack
		if arguments.size == 1
			data = arguments[0]
			@id = data[:id]
			@name = data[:name]
			@isAdministrator = data[:isAdministrator]
		else
			@id, @name, @isAdministrator = arguments
		end
	end
end
