require 'sequel'

def getDatabase(configuration)
	begin
		data = configuration::Database
		
		database =
			Sequel.connect(
				adapter: data::Adapter,
				host: data::Host,
				user: data::User,
				password: data::Password,
				database: data::Database
			)
	
		#run an early test to see if the DBMS is accessible
		database[:user_data].where(name: '').all
		return database
	rescue Sequel::DatabaseConnectionError => exception
		puts "DBMS inaccessible: #{exception.message}"
		exit
	end
end
