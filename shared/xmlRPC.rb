require 'configuration/Configuration'

require 'shared/XMLRPCClient'

def getXMLRPCClient(configuration = Configuration::XMLRPC)
	client = XMLRPCClient.new(
		configuration::Host,
		configuration::Port,
		configuration::Path,
	)
	return client
end
