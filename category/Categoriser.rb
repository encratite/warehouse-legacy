require 'fileutils'
require 'etc'

require 'nil/time'
require 'nil/file'
require 'nil/environment'

require 'shared/sites'

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
		@sites = getReleaseSites
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
	
	def processMatch(release, user, category, filter, isNFO = false)
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
			filterName = isNFO ? 'NFO filter' : 'name filter'
			output "Creating symlink #{symlink} to release #{target} because of the #{filterName} \"#{filter}\" of user #{user}"
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
	
	def getNFO(release)
		@sites.each do |site|
			table = site.table
			result = @database[table].where(name: release).select(:nfo)
			next if result.empty?
			nfo = result.first[:nfo]
			next if nfo == nil
			return nfo
		end
		return
	end
	
	def processResults(results, release, isNFO = false)
		results.each do |result|
			user = result[:user_name]
			category = result[:category]
			filter = result[:filter]
			[@ownPath, category].compact.each do |currentCategory|
				processMatch(release, user, currentCategory, filter, isNFO)
			end
		end
	end
	
	def categorise(release)
		query = 'select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.category as category from user_data inner join user_release_filter on (user_data.id = user_release_filter.user_id) where ? ~* user_release_filter.filter'
		#process filter matches by name
		results = @database["#{query} and user_release_filter.is_nfo_filter = false", release]
		processResults(results, release)
		
		#process filter matches by NFO content
		nfo = getNFO(release)
		if nfo != nil
			output "Found an NFO of #{nfo.size} bytes in size for release #{release}"
			results = @database["#{query} and user_release_filter.is_nfo_filter = true", nfo]
			processResults(results, release, true)
		else
			output "Found no NFO for release #{release}"
		end
		
		#always create a symlink for manually queued releases
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
