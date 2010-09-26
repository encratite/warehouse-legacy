$: << '.'

require 'nil/file'
require 'json/JSONRPCHTTPServer'
require 'configuration/Configuration'
require 'shared/ConnectionContainer'

log = Nil.joinPaths(Configuration::Logging::Path, Configuration::JSONRPCServer::Log)
server = JSONRPCHTTPServer.new(Configuration, ConnectionContainer.new, log)

handler = lambda do |environment|
	server.processRequest(environment)
end

run handler
