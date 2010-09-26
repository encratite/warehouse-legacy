require_relative 'shared/ConnectionContainer'

connections = ConnectionContainer.new
connections.notificationClient.notify('torment', 'test', 'null')
