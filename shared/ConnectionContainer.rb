require 'shared/sqlDatabase'
require 'shared/xmlRPC'
require 'shared/NotificationProtocolClient'

require 'configuration/Configuration'

class ConnectionContainer
	attr_reader :sqlDatabase, :xmlRPCClient, :notificationClient
	
	def initialize
		@sqlDatabase = getSQLDatabase
		@xmlRPCClient = getXMLRPCClient
		@notificationClient = NotificationProtocolClient.new(Configuration::Notification::Socket)
	end
end
