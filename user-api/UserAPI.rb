require 'nil/file'

require 'shared/SearchResult'
require 'shared/sites'

class UserAPI
	class Error < Exception
	end
	
	def initialize(configuration, database, user)
		@configuration = configuration
		
		@filterLengthMaximum = configuration::Shell::FilterLengthMaximum
		@filterCountMaximum = configuration::Shell::FilterCountMaximum
		@searchResultMaximum = configuration::Shell::SearchResultMaximum
		@commandLogCountMaximum = configuration::Shell::CommandLogCountMaximum
		
		@sshKeyMaximum = configuration::Shell::SSHKeyMaximum
		
		@releaseSizeLimit = configuration::Torrent::SizeLimit
		
		@database = database
		
		@torrentPath = configuration::Torrent::Path::Torrent
		@userPath = Nil.joinPaths(configuration::Torrent::Path::User, @user.name)
		@filteredPath = Nil.joinPaths(@userPath, configuration::Torrent::Path::Filtered)
		@nic = configuration::Torrent::NIC
		
		@filters = @database[:user_release_filter]
		@logs = @database[:user_command_log]
		
		@sites = getReleaseSites
		
		@database = database
		@user = user
	end
	
	def error(message)
		raise Error.new(message)
	end
end
