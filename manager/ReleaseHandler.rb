require 'sequel'
require 'pg'
require 'database'

require 'nil/file'

class ReleaseHandler
	def initialize(manager, configuration, releaseTableSymbol, releaseDataClass)
		@http = manager.http
		@torrentPath = configuration::Torrent::Path::Torrent
		@sizeLimit = configuration::Torrent::SizeLimit
		@database = getDatabase configuration
		@manager = manager
		
		@releaseDataClass = releaseDataClass
		@releaseTableSymbol = releaseTableSymbol
	end
	
	def databaseDown(exception)
		output "The DBMS appears to be down: #{exception.message}"
		exit
	end
	
	def isReleaseOfInterest(release, nfo)
		if nfo == nil
			results = @database["select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.is_nfo_filter as is_nfo_filter from user_release_filter, user_data where (user_release_filter.is_nfo_filter = false and ? ~* user_release_filter.filter) and user_data.id = user_release_filter.user_id", release]
		else
			results = @database["select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.is_nfo_filter as is_nfo_filter from user_release_filter, user_data where ((user_release_filter.is_nfo_filter = false and ? ~* user_release_filter.filter) or (user_release_filter.is_nfo_filter = true and ? ~* user_release_filter.filter)) and user_data.id = user_release_filter.user_id", release, nfo]
		end
		
		matchCount = results.count
		isOfInterest = matchCount > 0
		if isOfInterest
			output "Matches"
			filterDictionary = {}
			results.each do |row|
				name = row[:user_name]
				filter = row[:filter]
				isNfo = row[:is_nfo_filter]
				filterDictionary[name] = [] if filterDictionary[name] == nil
				filter += ' (NFO)' if isNfo
				filterDictionary[name] << filter
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
			dataset = @database[releaseTableSymbol]
			result = dataset.where(site_id: insertData[:site_id])
			if result.count > 0
				puts 'This entry already exists - overwriting it'
				dataset.delete
			end
			dataset.insert(insertData)
		rescue	Sequel::DatabaseError => exception
			output "DBMS exception: #{exception.message}"
		end
	end
	
	def output(line)
		@manager.console.output(line)
	end
	
	def processMessage(release, url)
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
			releaseData = @releaseDataClass.new(data)
			isOfInterest = false
			@database.transaction do
				insertData(releaseData)
				isOfInterest = isReleaseOfInterest(release, releaseData.nfo)
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
		rescue @releaseTableSymbol::Error => exception
			output "Error: Unable to parse data from release #{release} at #{url}: #{exception.message}"
		end
	end
end
