$: << '.'

require 'configuration/Configuration'
require 'notification/NotificationServer'
require 'shared/ConnectionContainer'

server = NotificationServer.new(Configuration, ConnectionContainer.new)
server.run
