$:.concat ['../shared']

require 'sequel'

require 'nil/environment'

require 'database'
require 'HTTPHandler'
require 'Configuration'

require 'Shell'
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
				id = userData.insert(name: username, is_administrator: true)
				puts "Welcome, #{username}! You have been made an administrator."
				user = User.new(id, username, true)
			else
				#it's not the first user, add them to the system
				id = userData.insert(name: username)
				puts "Welcome to the system, #{username}!"
				user = User.new(id, username)
			end
			
			puts "Use the 'help' command to familiarise yourself with this environment."
		else
			puts "Welcome back, #{username}."
			currentUserData = dataset.first
			user = User.new(currentUserData[:id], username, currentUserData[:is_administrator])
		end
	end

	return user
end

def getHTTPHandler(configuration)
	http = HTTPHandler.new(configuration::Cookie::UId, configuration::Cookie::Pass)
	return http
end

database = getDatabase Configuration
http = getHTTPHandler Configuration
user = getUser database
shell = Shell.new(nil, nil)
shell = Shell.new(Configuration, database, user, http)
shell.run
