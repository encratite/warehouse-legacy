$: += ['shared', 'site/scene-access', 'site/torrentvault']

require 'sequel'

require 'nil/environment'
require 'nil/console'

require 'database'
require 'HTTPHandler'
require 'Configuration'

require 'UserShell'
require 'User'

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
				user = User.new(id, username, true)
			else
				#it's not the first user, add them to the system
				id = userData.insert(name: username)
				puts "Welcome to the system, #{highlightedName}!"
				user = User.new(id, username)
			end
			
			puts "Use the '#{Nil.white 'help'}' command to familiarise yourself with this environment."
		else
			puts "Welcome back, #{highlightedName}."
			currentUserData = dataset.first
			user = User.new(currentUserData[:id], username, currentUserData[:is_administrator])
		end
	end

	return user
end

def getHTTPHandler(configuration)
	sccData = configuration::SceneAccess::HTTP
	http = HTTPHandler.new(sccData::Server, sccData::Cookies)
	return http
end

database = getDatabase
http = getHTTPHandler Configuration
user = getUser database
shell = UserShell.new(Configuration, database, user, http)
shell.run
