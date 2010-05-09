require 'Configuration'

def getSiteLogPath(filename)
	return Configuration::Logging::SitePath + filename
end
