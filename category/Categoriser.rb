require 'nil/time'
require 'nil/file'
require 'nil/environment'

require 'fileutils'
require 'etc'

class Categoriser
	def initialize(configuration, database)
		@userBind = configuration::Torrent::Path::UserBind
		@filteredPath = configuration::Torrent::Path::Filtered
		@ownPath = configuration::Torrent::Path::Own
		@userPath = configuration::Torrent::Path::User
		@database = database
		@log = File.open(configuration::Logging::CategoriserLog, 'ab')
		@shellGroup = configuration::Torrent::User::ShellGroup
		@user = Nil.getUser
		@torrentPath = configuration::Torrent::Path::Torrent
		@manualPath = configuration::Torrent::Path::Manual
	end
	
	def output(line)
		line = "#{Nil.timestamp} #{line}"
		puts line
		@log.puts(line)
	end
	
	def setupPermissions(path)
		FileUtils.chown(@user, @shellGroup, path)
		FileUtils.chmod(0775, path)
	end
	
	def processMatch(release, user, category, filter)
		category = @ownPath if category == nil
		userPath = Nil.joinPaths(@userPath, user)
		filterPath = Nil.joinPaths(userPath, @filteredPath)
		categoryPath = filterPath
		categoryTokens = category.split '/'
		categoryTokens.each do |token|
			categoryPath = Nil.joinPaths(categoryPath, token)
			begin
				FileUtils.mkdir categoryPath
				output "Created path #{categoryPath}"
			rescue Errno::EEXIST
			end
			setupPermissions(categoryPath)
		end
		symlink = Nil.joinPaths(categoryPath, release)
		target = Nil.joinPaths(@userBind, release)
		if filter == nil
			output "Creating symlink #{symlink} to release #{target} because user #{user} manually downloaded this release"
		else
			output "Creating symlink #{symlink} to release #{target} because of the filter \"#{filter}\" of user #{user}"
		end
		begin
			Nil.symbolicLink(target, symlink)
		rescue Errno::EEXIST
			output 'Warning: Link already exists'
		rescue NotImplementedError
			output 'Error: Symlinks not implemented!'
			return
		end
		setupPermissions(symlink)
	end
	
	def categorise(release)
		results = @database['select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.category as category from user_data inner join user_release_filter on (user_data.id = user_release_filter.user_id) where ? ~* user_release_filter.filter', release]
		results.each do |result|
			user = result[:user_name]
			category = result[:category]
			filter = result[:filter]
			[@ownPath, category].compact.each do |currentCategory|
				processMatch(release, user, currentCategory, filter)
			end
		end
		
		begin
			torrentName = "#{release}.torrent"
			torrentPath = Nil.joinPaths(@torrentPath, torrentName)
			stat = File.stat(torrentPath)
			user = Etc.getpwuid(stat.uid).name
			group = Etc.getgrgid(stat.gid).name
			if group == @shellGroup
				processMatch(release, user, @manualPath, nil)
			end
		rescue Errno::ENOENT
			output "No such path: #{torrentPath}"
		end
	end
end
