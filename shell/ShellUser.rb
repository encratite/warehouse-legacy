require_relative 'shared/User'
require 'nil/console'

class ShellUser < User
	def shellPrefix
		return isAdministrator ?
			Nil.cyan('# ') :
			Nil.green('$ ')
	end
end
