require 'nil/time'

class Categoriser
	def initialize(configuration, database)
		@userBind = configuration::Torrent::Path::UserBind
		@userPath = configuration::Torrent::Path::User
		@database = database
		@log = File.open(configuration::Logging::CategoriserLog, 'ab')
	end
	
	def output(line)
		line = "#{Nil.timestamp} #{line}"
		puts line
		@log.puts(line)
	end
	
	def categorise(release)
		results = @database['select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.category as category from user_data inner join user_release_filter on (user_data.id = user_release_filter.user_id) where ? ~* user_release_filter.filter', release]
		results.each do |result|
			user = result[:user_name]
			userPath = File.expand_path(user, @userPath)
			symlink = File.expand_path(release, userPath)
			target = "#{@userBind}/release"
			output "Creating symlink #{symlink} because of the following filter: #{result[:filter]}"
			begin
				File.symlink(target, symlink)
			rescue NotImplementedError
				puts 'Error: Symlinks not implemented!'
			end
		end
	end
end
