require 'fileutils'
require 'etc'

require 'nil/time'
require 'nil/file'
require 'nil/environment'

require 'shared/sites'
require 'shared/torrent'

require 'notification/NotificationReleaseData'

class Categoriser
	def initialize(configuration, connections)
		@userBind = configuration::Torrent::Path::UserBind
		@filteredPath = configuration::Torrent::Path::Filtered
		@ownPath = configuration::Torrent::Path::Own
		@userPath = configuration::Torrent::Path::User
		
		@database = connections.sqlDatabase
		@queue = @database[:download_queue]
		
		@notification = connections.notificationClient
		
		@connections = connections
		@log = File.open(configuration::Logging::CategoriserLog, 'ab')
		@shellGroup = configuration::User::ShellGroup
		@user = Nil.getUser
		@torrentPath = configuration::Torrent::Path::Torrent
		@manualPath = configuration::Torrent::Path::Manual
		@sites = getReleaseSites(connections)
	end
	
	def output(line)
		line = "#{Nil.timestamp} #{line}"
		puts line
		@log.puts(line)
	end
	
	def setupPermissions(path)
		output "Modifying the permissions of #{path}: chown #{@user}:#{@shellGroup}"
		user, group = getUserAndGroup path
		output "The current user and group of #{path} are #{user}:#{group}"
		FileUtils.chown(@user, @shellGroup, path)
		FileUtils.chmod(0775, path)
	end
	
	#returns if the release was queued manually or not
	def processMatch(release, user, category, filter, type, releaseData)
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
		
		if releaseData.isManual
			output "Creating symlink #{symlink} to release #{target} because user #{user} manually downloaded this release"
		else
			output "Creating symlink #{symlink} to release #{target} because of filter \"#{filter}\" [#{type}] of user #{user}"
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
		return releaseData
	end
	
	def getSpecificReleaseInformation(release)
		targets =
		[
			:nfo
		]
		output = {}
		@sites.each do |site|
			table = site.table
			actualTargets = targets
			if site == 'TV'
				#only TorrentVault has genres for MP3/TV releases right now
				actualTargets += [:genre]
			end
			results = @database[table].where(name: release).select(*actualTargets)
			results = results.all
			next if results.empty?
			result = results[0]
			actualTargets.each do |target|
				input = result[target]
				output[target] = input if input != nil
			end
		end
		return output
	end
	
	#returns if one of the releases was queued manually (in that case there should be only one really)
	def processResults(results, release, type)
		isManual = false
		results.each do |result|
			user = result[:user_name]
			category = result[:category]
			filter = result[:filter]
			categories = [@ownPath, category].compact
			if !categories.empty?
				releaseData = NotificationReleaseData.fromTable(release, @database)
				categories.each do |currentCategory|
					releaseData = processMatch(release, user, currentCategory, filter, type, releaseData)
					isManual = releaseData.isManual || isManual
				end
				#notify the user(s) (how could it even be more than one? whatever...) about their download
				rows = @database[:download_queue_user].where(queue_id: releaseData.id).select(:user_id)
				rows.each do |data|
					@notification.downloadedNotification(data[:user_id], releaseData)
				end
				#the release is not longer part of the queue - remove it
				@queue.where(id: releaseData.id).delete
			end
		end
		return isManual
	end
	
	def getUserAndGroup(path)
		if File.symlink?(path)
			stat = File.lstat(path)
		else
			stat = File.stat(path)
		end
		user = Etc.getpwuid(stat.uid).name
		group = Etc.getgrgid(stat.gid).name
		return user, group
	end
	
	def getFilterCondition(type)
		return "user_release_filter.release_filter_type = '#{type}'"
	end
	
	def performQuery(release, type, data)
		query = 'select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.category as category from user_data inner join user_release_filter on (user_data.id = user_release_filter.user_id) where ? ~* user_release_filter.filter'
		results = @database["#{query} and #{getFilterCondition type}", data].all
		return processResults(results, release, type)
	end
	
	def categorise(release)
		@database.transaction do
			begin
				output "Categorising release #{release}"
				#process filter matches by name
				isManual = performQuery(release, 'name', release)
				
				infoHash = getSpecificReleaseInformation release
				
				#process filter matches by NFO content
				nfo = infoHash[:nfo]
				if nfo != nil
					output "Found an NFO of #{nfo.size} bytes in size for release #{release}"
					performQuery(release, 'nfo', nfo)
				else
					output "Found no NFO for release #{release}"
				end
				
				genre = infoHash[:genre]
				if genre != nil
					output "#{release} appears to be a release of genre #{genre}"
					performQuery(release, 'genre', genre)
				else
					output "No genre was specified for release #{release}"
				end
				
				#always create a symlink for manually queued releases
				begin
					torrentName = Torrent.getTorrentName(release)
					torrentPath = Nil.joinPaths(@torrentPath, torrentName)
					if isManual
						releaseData = NotificationReleaseData.fromTable(release, @database)
						processMatch(release, user, @manualPath, nil, nil, releaseData)
					end
				rescue Errno::ENOENT
					output "No such path: #{torrentPath}"
				end
			rescue => exception
				message = "An exception of type #{exception.class} occured: #{exception.message}\n"
				message += exception.backtrace.join("\n")
				output message
				exit
			end
		end
	end
end
