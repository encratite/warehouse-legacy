class User
	attr_reader :id, :name, :isAdministrator
	attr_writer :lastNotification
	
	def initialize(*arguments)
		#overloaded constructor hack
		if arguments.size == 1
			data = arguments[0]
			@id = data[:id]
			@name = data[:name]
			@isAdministrator = data[:is_administrator]
			@lastNotification = data[:last_notification]
		else
			@id, @name, @isAdministrator = arguments
		end
	end
end
