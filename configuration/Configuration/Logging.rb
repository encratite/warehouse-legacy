require 'nil/file'

module Configuration
	module Logging
		Path = 'log'
		CategoriserLog = Nil.joinPaths(Path, 'categoriser.log')
	end
end
