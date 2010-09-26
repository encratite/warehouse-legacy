require_relative 'configuration/Configuration'
require_relative 'notification/NotificationServer'
require_relative 'shared/ConnectionContainer'

server = NotificationServer.new(Configuration, ConnectionContainer.new)
server.run
