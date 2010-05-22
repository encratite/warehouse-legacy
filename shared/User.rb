class User
	attr_reader :id, :name, :isAdministrator
	
	def initialize(data)
		@id = data[:id]
		@name = data[:name]
		@isAdministrator = data[:isAdministrator]
	end
end
