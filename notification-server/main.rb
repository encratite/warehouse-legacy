require 'configuration/Configuration'
require 'notification-server/NotificationServer'
require 'shared/ConnectionContainer'

server = NotificationServer.new(Configuration::Notification, ConnectionContainer.new)
server.run
