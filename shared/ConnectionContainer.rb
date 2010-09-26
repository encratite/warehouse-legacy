require_relative 'shared/sqlDatabase'
require_relative 'shared/xmlRPC'
require_relative 'shared/NotificationProtocolClient'

require_relative 'configuration/Configuration'

class ConnectionContainer
	attr_reader :sqlDatabase, :xmlRPCClient, :notificationClient
	
	def initialize
		@sqlDatabase = getSQLDatabase
		@xmlRPCClient = getXMLRPCClient
		@notificationClient = NotificationProtocolClient.new(Configuration::Notification::Socket)
	end
end
