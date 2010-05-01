require 'nil/console'

class User
	attr_reader :id, :name, :isAdministrator
	
	def initialize(id, name, isAdministrator = false)
		@id = id
		@name = name
		@isAdministrator = isAdministrator
	end
	
	def shellPrefix
		return isAdministrator ?
			Nil.cyan('# ') :
			Nil.green('$ ')
	end
end
