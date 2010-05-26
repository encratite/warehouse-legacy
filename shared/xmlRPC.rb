require 'configuration/Configuration'
require 'xmlrpc/client'

def getXMLRPCClient(configuration = Configuration::XMLRPC)
	client = XMLRPC::Client.new(
		configuration::Host,
		configuration::Path,
		configuration::Port
	)
end
