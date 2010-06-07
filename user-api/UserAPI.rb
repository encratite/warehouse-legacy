require 'nil/file'
require 'nil/environment'

require 'shared/sites'
require 'shared/User'
require 'shared/QueueHandler'

[
	'general',
	'filters',
	'search',
	'category',
	'download',
	'rtorrent',
	'notifications',
].each do |name|
	require "user-api/UserAPI/#{name}"
end

class UserAPI
	class Error < Exception
	end
	
	attr_reader :sites
	
	#if user is equal to nil then the program will attempt to look up the current user
	def initialize(configuration, connections, user = nil)
		@configuration = configuration
		
		@connections = connections
		@database = connections.sqlDatabase
		@rpc = connections.xmlRPCClient
		
		processUser(user)
		
		@filterLengthMaximum = configuration::Shell::FilterLengthMaximum
		@filterCountMaximum = configuration::Shell::FilterCountMaximum
		@searchResultMaximum = configuration::Shell::SearchResultMaximum
		@commandLogCountMaximum = configuration::Shell::CommandLogCountMaximum
		
		@sshKeyMaximum = configuration::Shell::SSHKeyMaximum
		
		@releaseSizeLimit = configuration::Torrent::SizeLimit
		
		@torrentPath = configuration::Torrent::Path::Torrent
		@userPath = Nil.joinPaths(configuration::Torrent::Path::User, @user.name)
		@filteredPath = Nil.joinPaths(@userPath, configuration::Torrent::Path::Filtered)
		@nic = configuration::Torrent::NIC
		
		@filters = @database[:user_release_filter]
		
		@sites = getReleaseSites(@database)
		
		@changeOwnershipPath = configuration::API::ChangeOwnershipPath
		
		@queue = QueueHandler.new(@database)
	end
	
	def processUser(user)
		if user == nil
			user = Nil.getUser
			userData = @database[:user_data].where(name: user).all
			if userData.empty?
				raise "User #{user} was not found in the database."
			end
			@user = User.new(userData[0])
		else
			@user = user
		end
	end
	
	def error(message)
		raise Error.new(message)
	end
	
	def getSiteByName(name)
		@sites.each do |site|
			return site if site.name == name
		end
		error "Unable to find site \"#{name}\""
	end
	
	def isIllegalName(name)
		forbidden =
		[
			'..',
			'/'
		]
		
		forbidden.each do |string|
			if name.index(string) != nil
				return true
			end
		end
		
		return false
	end
end
