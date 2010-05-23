require 'rpc/JSONServer'
require 'configuration/Configuration'
require 'nil/file'

logPath = Nil.joinPaths(Configuration::Logging::Path, Configuration::RPCServer::Log)
server = JSONServer.new(Configuration::RPCServer::SessionCookie, logPath)

handler = lambda do |environment|
	server.processRequest(environment)
end

run handler
