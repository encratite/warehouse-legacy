require 'shared/sqlDatabase'
require 'shared/xmlRPC'

class ConnectionContainer
	attr_reader :sqlDatabase, :xmlRPCClient
	
	def initialize
		@sqlDatabase = getSQLDatabase
		@xmlRPCClient = getXMLRPCClient
	end
end
