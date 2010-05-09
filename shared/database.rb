require 'sequel'

require 'Configuration'

def getDatabase(data = Configuration::Database)
	begin
		database =
			Sequel.connect(
				adapter: data::Adapter,
				host: data::Host,
				user: data::User,
				password: data::Password,
				database: data::Database
			)
	
		#run an early test to see if the DBMS is accessible
		database['select 1 where true'].all
		return database
	rescue Sequel::DatabaseConnectionError => exception
		puts "DBMS inaccessible: #{exception.message}"
		exit
	end
end
