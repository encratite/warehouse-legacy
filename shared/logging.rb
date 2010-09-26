require 'configuration/Configuration'

require 'nil/file'

def getSiteLogPath(filename)
	return Nil.joinPaths(Configuration::Logging::Path, filename)
end
