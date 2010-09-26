$: << '.'

require 'shared/ConnectionContainer'

connections = ConnectionContainer.new
connections.notificationClient.notify('torment', 'test', nil)
