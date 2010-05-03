require 'sequel'
require 'pg'
require 'ReleaseData'
require 'database'

require 'nil/file'

class ReleaseHandler
	def initialize(manager, configuration)
		@http = manager.http
		@torrentPath = configuration::Torrent::TorrentPath
		@sizeLimit = configuration::Torrent::SizeLimit
		@database = getDatabase configuration
		@manager = manager
	end
	
	def databaseDown(exception)
		output "The DBMS appears to be down: #{exception.message}"
		exit
	end
	
	def isReleaseOfInterest(release, caseSensitive)
		if release == nil
			puts 'Release is nil!'
			exit
		end
		operator =
			caseSensitive ?
			'~' :
			'~*'
		result = @database["select user_data.name as user_name, user_release_filter.filter as user_filter from user_release_filter, user_data where ? #{operator} user_release_filter.filter and user_data.id = user_release_filter.user_id and user_release_filter.is_case_sensitive = ?", release, caseSensitive]
		matchCount = result.count
		isOfInterest = matchCount > 0
		if isOfInterest
			output "Matches with operator #{operator}:"
			filterDictionary = {}
			result.each do |row|
				name = row[:user_name]
				filterDictionary[name] = [] if filterDictionary[name] == nil
				filterDictionary[name] << row[:user_filter]
			end
			filterDictionary.each do |name, filters|
				output "#{name}: #{filters.inspect}"
			end
		end
		return isOfInterest
	end
	
	def insertData(releaseData)
		begin
			insertData = releaseData.getData
			@database[:scene_access_data].insert(insertData)
		rescue	Sequel::DatabaseError => exception
			output "DBMS exception: #{exception.message}"
		end
	end
	
	def output(line)
		@manager.console.output(line)
	end
	
	def processMessage(release, url)
		puts "processMessage called with #{release.inspect}, #{url.inspect}"
		prefix = 'http://'
		return if url.size <= prefix.size
		offset = url.index('/', prefix.size)
		path = url[offset..-1]
		data = @http.get(path)
		if data == nil
			output "Error: Failed to retrieve URL #{url} (path: #{path}, release; #{release})"
			return
		end
		begin
			releaseData = ReleaseData.new(data)
			isOfInterest = false
			@database.transaction do
				insertData(releaseData)
				isOfInterest = isReleaseOfInterest(release, false) || isReleaseOfInterest(release, true)
			end
			if isOfInterest
				output "Discovered a release of interest: #{release}"
				if releaseData.size > @sizeLimit
					output "Unluckily the size of this release exceeds the limit (#{releaseData.size} > #{@sizeLimit})"
					return
				end
				path = releaseData.path
				torrentMatch = /\/([^\/]+\.torrent)/.match(path)
				if torrentMatch == nil
					output "Failed to retrieve the torrent name from the torrent path: #{path}"
					return
				end
				torrent = torrentMatch[1]
				output "Downloading #{path}"
				torrentData = @http.get(path)
				torrentPath = File.expand_path(torrent, @torrentPath)
				Nil.writeFile(torrentPath, torrentData)
				output "Downloaded #{path} to #{torrentPath}"
			else
				output "#{release} is not a release of interest"
			end
		rescue Sequel::DatabaseConnectionError => exception
			databaseDown exception
		rescue ReleaseData::Error => exception
			output "Error: Unable to parse data from release #{release} at #{url}: #{exception.message}"
		end
	end
end
