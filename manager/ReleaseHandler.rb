require 'sequel'

class ReleaseHandler
	def initialize(configuration)
		databaseConfiguration = configuration.const_get(:Database)
		@database =
			Sequel.connect(
				adapter: databaseConfiguration.const_get(:Adapter),
				host: databaseConfiguration.const_get(:Host),
				user: databaseConfiguration.const_get(:User),
				password: databaseConfiguration.const_get(:Password),
				database: databaseConfiguration.const_get(:Database)
			)
			
		#Sequel::DatabaseConnectionError
	end
	
	def processMessage(release, url)
	end
end
