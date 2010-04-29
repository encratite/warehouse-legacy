$:.concat '../shared'

require 'nil/environment'
require 'sequel'
require 'database'
require 'Configuration'

database = getDatabase Configuration

user = Nil.getUser

userData = database[:user_data]

isAdministrator = false

database.transaction do
	dataset = userData.where(name: user)
	if dataset.empty?
		#new user, possibly even the first user
		if userData.count == 0
			#make the user an administrator, they are the first user to connect
			userData.insert(name: user, is_administrator: true)
			puts "Welcome, #{user}! You have been made administrator."
			isAdministrator = true
		else
			#it's not the first user, add them to the system
			userData.insert(name: user)
			puts "Welcome to the system, #{user}!"
		end
	else
		puts "Welcome back, #{user}."
		isAdministrator = dataset.first.is_administrator
	end
end
