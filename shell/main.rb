require 'sequel'

require 'nil/environment'
require 'nil/console'

require 'shared/ConnectionContainer'
require 'shared/http/HTTPHandler'

require 'configuration/Configuration'

require 'shell/UserShell'
require 'shell/ShellUser'

def getUser(database)
	username = Nil.getUser
	highlightedName = Nil.white username

	userData = database[:user_data]

	user = nil

	database.transaction do
		dataset = userData.where(name: username)
		if dataset.empty?
			#new user, possibly even the first user
			if userData.count == 0
				#make the user an administrator, they are the first user to connect
				id = userData.insert(name: username, is_administrator: true)
				puts "Welcome, #{highlightedName}! You have been made an administrator."
				user = ShellUser.new(id, username, true)
			else
				#it's not the first user, add them to the system
				id = userData.insert(name: username)
				puts "Welcome to the system, #{highlightedName}!"
				user = ShellUser.new(id, username, false)
			end
			
			puts "Use the '#{Nil.white 'help'}' command to familiarise yourself with this environment."
		else
			puts "Welcome back, #{highlightedName}."
			currentUserData = dataset.first
			user = ShellUser.new(currentUserData[:id], username, currentUserData[:is_administrator])
		end
	end

	return user
end

connections = ConnectionContainer.new
user = getUser(connections.sqlDatabase)
shell = UserShell.new(Configuration, connections, user)
shell.run
