require 'rpc/JSONServer'
require 'configuration/Configuration'

server = JSONServer.new(Configuration)

handler = lambda do |environment|
	server.processRequest(environment)
end

run handler
