class User
	attr_reader :id, :name, :isAdministrator
	
	def initialize(id, name, isAdministrator = false)
		@id = id
		@name = name
		@isAdministrator = isAdministrator
	end
	
	def shellPrefix
		return isAdministrator ?
			'# ' :
			'$ '
	end
end
