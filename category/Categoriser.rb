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
		#output "Modifying the permissions of #{path}: chown #{@user}:#{@shellGroup}"
		user, group = getUserAndGroup path
		#output "The current user and group of #{path} are #{user}:#{group}"
		FileUtils.chown(@user, @shellGroup, path)
		FileUtils.chmod(0775, path)
	end
	
	#returns if the release was queued manually or not
	def processMatch(releaseData, user, category, filter = nil, type = nil)
		#puts "processMatch: #{[releaseData, user, category, filter, type].inspect}"
		
		isOwn = category == @ownPath
		
		release = releaseData.name
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
		
		if !isOwn
			if releaseData.isManual
				output "Creating symlink #{symlink} to release #{target} because user #{user} manually downloaded this release"
			else
				output "Creating symlink #{symlink} to release #{target} because of filter \"#{filter}\" [#{type}] of user #{user}"
			end
		end
		
		begin
			Nil.symbolicLink(target, symlink)
			if isOwn
				output "Created symlink #{symlink} to release #{target}"
			end
		rescue Errno::EEXIST
			if !isOwn
				output 'Warning: Link already exists'
			end
		rescue NotImplementedError
			output 'Error: Symlinks not implemented!'
			return
		end
		setupPermissions(symlink)
		
		if !isOwn
			#create the filtered/own link
			processMatch(releaseData, user, @ownPath)
		end
		
		return nil
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
	
	def processResults(results, releaseData, type)
		results.each do |result|
			user = result[:user_name]
			category = result[:category]
			filter = result[:filter]
			categories = [@ownPath, category].compact
			if !categories.empty?
				categories.each do |currentCategory|
					processMatch(releaseData, user, currentCategory, filter, type)
				end
				#notify the user(s) (how could it even be more than one? whatever...) about their download
				rows = @database[:download_queue_user].where(queue_id: releaseData.id).select(:user_id)
				rows.each do |data|
					@notification.downloadedNotification(data[:user_id], releaseData)
				end
			end
		end
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
	
	def performQuery(releaseData, type, data)
		query = 'select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.category as category from user_data inner join user_release_filter on (user_data.id = user_release_filter.user_id) where ? ~* user_release_filter.filter'
		results = @database["#{query} and #{getFilterCondition type}", data].all
		processResults(results, releaseData, type)
		return nil
	end
	
	def categorise(release)
		@database.transaction do
			begin
				output "Categorising release #{release}"
				
				begin
					releaseData = NotificationReleaseData.fromTable(release, @database)
				rescue RuntimeError => exception
					puts "Notification release data error: #{exception.message}"
					return
				end
				
				#process filter matches by name
				performQuery(releaseData, 'name', release)
				
				infoHash = getSpecificReleaseInformation release
				
				#process filter matches by NFO content
				nfo = infoHash[:nfo]
				if nfo != nil
					output "Found an NFO of #{nfo.size} bytes in size for release #{release}"
					performQuery(releaseData, 'nfo', nfo)
				else
					output "Found no NFO for release #{release}"
				end
				
				genre = infoHash[:genre]
				if genre != nil
					output "#{release} appears to be a release of genre #{genre}"
					performQuery(releaseData, 'genre', genre)
				else
					output "No genre was specified for release #{release}"
				end
				
				#always create a symlink for manually queued releases
				if releaseData.isManual
					userIds = @database[:download_queue_user].where(queue_id: releaseData.id).select(:user_id).all
					if userIds.empty?
						output "Error: Unable to find a user ID associated with queue entry #{releaseData.id} (#{release})"
						return
					end
					userId = userIds.first[:user_id]
					users = @database[:user_data].where(id: userId).select(:name).all
					if users.empty?
						output "Error: Unable to determine the name of the user associated with ID #{userId}"
						return
					end
					username = users.first[:name]
					processMatch(releaseData, username, @manualPath)
				end
				
				@queue.where(name: releaseData.name).delete
			rescue => exception
				message = "An exception of type #{exception.class} occured: #{exception.message}\n"
				message += exception.backtrace.join("\n")
				output message
				exit
			end
		end
	end
end
