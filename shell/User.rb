class User
	attr_reader :name, :isAdministrator
	
	def initialize(name, isAdministrator = false)
		@name = name
		@isAdministrator = isAdministrator
	end
end
