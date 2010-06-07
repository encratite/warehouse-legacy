require 'configuration/Configuration'
require 'notifiation/NotificationServer'
require 'shared/ConnectionContainer'

server = NotificationServer.new(Configuration, ConnectionContainer.new)
server.run
