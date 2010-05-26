require 'shared/database'
require 'shared/xmlRPC'

class ConnectionContainer
	attr_reader :database, :xmlRPC
	
	def initialize
		@database = getSQLDatabase
		@xmlRPC = getXMLRPCClient
	end
end
