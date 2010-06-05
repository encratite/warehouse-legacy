require 'shared/sqlDatabase'
require 'shared/xmlRPC'
require 'shared/NotificationClient'

require 'configuration/Configuration'

class ConnectionContainer
	attr_reader :sqlDatabase, :xmlRPCClient, :notificationClient
	
	def initialize
		@sqlDatabase = getSQLDatabase
		@xmlRPCClient = getXMLRPCClient
		@notificationClient = NotificationClient.new(Configuration::Notification::Socket)
	end
end
