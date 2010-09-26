require_relative 'configuration/Configuration'

require_relative 'shared/XMLRPCClient'

def getXMLRPCClient(configuration = Configuration::XMLRPC)
	client = XMLRPCClient.new(
		configuration::Host,
		configuration::Port,
		configuration::Path,
	)
	return client
end
