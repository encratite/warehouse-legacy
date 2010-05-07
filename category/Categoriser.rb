require 'nil/time'
require 'nil/file'
require 'fileutils'

class Categoriser
	def initialize(configuration, database)
		@userBind = configuration::Torrent::Path::UserBind
		@filteredPath = configuration::Torrent::Path::Filtered
		@ownPath = configuration::Torrent::Path::Own
		@userPath = configuration::Torrent::Path::User
		@database = database
		@log = File.open(configuration::Logging::CategoriserLog, 'ab')
	end
	
	def output(line)
		line = "#{Nil.timestamp} #{line}"
		puts line
		@log.puts(line)
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
		end
		symlink = Nil.joinPaths(categoryPath, release)
		target = Nil.joinPaths(@userBind, release)
		output "Creating symlink #{symlink} to release #{target} because of the filter \"#{filter}\" of user #{user}"
		begin
			Nil.symbolicLink(target, symlink)
		rescue Errno::EEXIST
			output 'Warning: Link already exists'
		rescue NotImplementedError
			output 'Error: Symlinks not implemented!'
		end
	end
	
	def categorise(release)
		results = @database['select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.category as category from user_data inner join user_release_filter on (user_data.id = user_release_filter.user_id) where ? ~* user_release_filter.filter', release]
		results.each do |result|
			user = result[:user_name]
			category = result[:category]
			filter = result[:filter]
			output result.inspect
			[@ownPath, category].compact.each do |currentCategory|
				processMatch(release, user, currentCategory, filter)
			end
		end
	end
end
