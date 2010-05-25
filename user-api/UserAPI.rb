require 'nil/file'

require 'shared/sites'

[
	'general',
	'filters',
	'search',
	'category',
	'download',
].each do |name|
	require "user-api/UserAPI/#{name}"
end

class UserAPI
	class Error < Exception
	end
	
	def initialize(configuration, database, user)
		@configuration = configuration
		@user = user
		@database = database
		
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
		
		@sites = getReleaseSites
		
		@database = database
		@user = user
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
