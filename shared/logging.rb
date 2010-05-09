require 'configuration/Configuration'

def getSiteLogPath(filename)
	return Configuration::Logging::SitePath + filename
end
