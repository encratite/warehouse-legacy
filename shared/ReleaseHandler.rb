require 'sequel'
require 'pg'

require 'nil/file'

require 'database'
require 'ReleaseData'

class ReleaseHandler
	def initialize(site)
		@httpHandler = site.httpHandler
		@outputHandler = site.outputHandler
		
		@database = site.database
		
		@torrentPath = site.torrentPath
		@sizeLimit = site.releaseSizeLimit
		
		@releaseTableSymbol = site.releaseTableSymbol
		@releaseDataClass = site.releaseDataClass
	end
	
	def databaseDown(exception)
		output "The DBMS appears to be down: #{exception.message}"
		exit
	end
	
	def isReleaseOfInterest(release, nfo)
		select = 'select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.is_nfo_filter as is_nfo_filter from user_release_filter, user_data where'
		nameCondition = '(user_release_filter.is_nfo_filter = false and ? ~* user_release_filter.filter)'
		nfoCondition = '(user_release_filter.is_nfo_filter = true and ? ~* user_release_filter.filter)'
		idCondition = 'user_data.id = user_release_filter.user_id'
		if nfo == nil
			results = @database["#{select} #{nameCondition} and #{idCondition}", release]
		else
			results = @database["#{select} (#{nameCondition} or #{nfoCondition}) and #{idCondition}", release, nfo]
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
			dataset = @database[@releaseTableSymbol]
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
		@observer.console.output(line)
	end
	
	def processMessage(release, url)
		tokens = url.split('://')
		if tokens.size != 2
			output "Invalid URL: #{url}"
			return
		end
		
		#unused as of now, ignore https
		protocol = tokens[0]
		identifier = tokens[1]
		
		offset = identifier.index('/')
		path = identifier[offset..-1]
		data = @httpHandler.get(path)
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
					torrent = "#{release}.torrent"
				else
					torrent = torrentMatch[1]
				end
				if torrent.index('/') != nil
					output "Invalid torrent name: #{torrent}"
					return
				end
				torrentPath = File.expand_path(torrent, @torrentPath)
				if Nil.readFile(torrentPath) != nil
					output "Collision detected - aborting, #{torrentPath} already exists!"
					return
				end
				output "Downloading #{path}"
				torrentData = @httpHandler.get(path)
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
