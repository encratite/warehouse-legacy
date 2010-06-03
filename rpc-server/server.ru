require 'nil/file'
require 'json/JSONRPCHTTPServer'
require 'configuration/Configuration'

log = Nil.joinPaths(configuration::Logging::Path, Configuration::JSONRPCServer::Log)
server = JSONRPCHTTPServer.new(log)

handler = lambda do |environment|
	server.processRequest(environment)
end

run handler
