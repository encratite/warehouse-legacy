module Configuration
	module SQLDatabase
		Adapter = 'postgres'
		Host = '127.0.0.1'
		User = 'void'
		Password = ''
		SQLDatabase = 'warehouse'
		
		#this script is only used by the setup script
		Script = 'database/warehouse.sql'
	end
end
