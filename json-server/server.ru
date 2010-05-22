require 'rpc/JSONServer'
require 'configuration/Configuration'
require 'nil/file'

logPath = Nil.joinPaths(Configuration::Logging::Path, Configuration::RPCServer::RPCLog)
server = JSONServer.new(RPCServer::Log, logPath)

run do |environment|
	server.processRequest(environment)
end
