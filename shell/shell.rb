$:.concat '../shared'

require 'nil/environment'
require 'sequel'
require 'database'
require 'Configuration'

require 'User'

def getUser(database)
	username = Nil.getUser

	userData = database[:user_data]

	user = nil

	database.transaction do
		dataset = userData.where(name: username)
		if dataset.empty?
			#new user, possibly even the first user
			if userData.count == 0
				#make the user an administrator, they are the first user to connect
				userData.insert(name: username, is_administrator: true)
				puts "Welcome, #{username}! You have been made administrator."
				user = User.new(username, true)
			else
				#it's not the first user, add them to the system
				userData.insert(name: username)
				puts "Welcome to the system, #{username}!"
				user = User.new(username)
			end
		else
			puts "Welcome back, #{username}."
			isAdministrator = dataset.first.is_administrator
			user = User.new(username, isAdministrator)
		end
	end

	return user
end

database = getDatabase Configuration
user = getUser database
