require 'sequel'
require 'pg'

require 'nil/file'

require 'shared/database'
require 'shared/ReleaseData'

class ReleaseHandler
	def initialize(site)
		@httpHandler = site.httpHandler
		@outputHandler = site.outputHandler
		#regular ReleaseSites don't have this member
		@downloadDelay = site.instance_variable_get(:@downloadDelay) || 0
		
		@database = site.database
		
		@torrentPath = site.torrentPath
		@sizeLimit = site.releaseSizeLimit
		
		@releaseTableSymbol = site.table
		@releaseDataClass = site.releaseDataClass
	end
	
	def databaseDown(exception)
		output "The DBMS appears to be down: #{exception.message}"
		exit
	end
	
	#type is :name, :nfo or :genre
	def isReleaseOfInterestType(releaseData, type)
		release = releaseData.name
		
		select = 'select user_data.name as user_name, user_release_filter.filter as filter, user_release_filter.release_filter_type as release_filter_type from user_release_filter, user_data'
		regexp = '? ~* user_release_filter.filter'
		
		typeString = type.to_s
		
		regexpCondition = '? ~* user_release_filter.filter'
		filterCondition = "user_release_filter.release_filter_type = ?"
		idCondition = 'user_data.id = user_release_filter.user_id'
	
		symbolString = "@#{type.to_s}"
		symbol = symbolString.to_sym
		
		if !releaseData.instance_variables.include?(symbol)
			#genres are not supported by all sites
			return false if type == :genre
			puts releaseData.inspect
			raise "Failed to retrieve instance variable of release #{releaseData.name} (symbol: #{type})"
		end
		target = releaseData.instance_variable_get(symbol)
		results = @database["#{select} where #{regexpCondition} and #{filterCondition} and #{idCondition}", target, typeString]
		matchCount = results.count
		isOfInterest = matchCount > 0
		if isOfInterest
			output "Matches for release #{release}: #{matchCount}"
			filterDictionary = {}
			results.each do |row|
				name = row[:user_name]
				filter = row[:filter]
				filterDictionary[name] = [] if filterDictionary[name] == nil
				filterDictionary[name] << "#{filter} (#{typeString})"
			end
			filterDictionary.each do |name, filters|
				output "#{name}: #{filters.inspect}"
			end
		end
		return isOfInterest
	end
	
	def isReleaseOfInterest(releaseData)
		types =
		[
			:name,
			:nfo,
			:genre
		]
		
		isOfInterest = false
		types.each do |type|
			isOfInterest = isReleaseOfInterestType(releaseData, type) || isOfInterest
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
		@outputHandler.output(line)
	end
	
	def processReleaseURL(release, url)
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
		processReleasePath(release, path)
	end
	
	def processReleasePath(release, path)
		processReleasePath(release, [path])
	end
	
	def processReleasePaths(release, paths)
		pages = []
		paths.each do |path|
			result = @httpHandler.get(path)
			if result == nil
				output "Error: Failed to retrieve path #{path} for release #{release}"
				return
			end
			pages << result
			sleep @downloadDelay
		end
		processReleaseData(release, pages)
	end
	
	def processReleaseData(release, pages)
		begin
			#reduce the array to its first element if possible, for the sake of not breaking the old release data classes
			if pages.size == 1
				input = pages[0]
			else
				input = pages
			end
			releaseData = @releaseDataClass.new(input)
			isOfInterest = false
			@database.transaction do
				insertData(releaseData)
				isOfInterest = isReleaseOfInterest(releaseData)
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
			output "Error: Unable to parse data of release #{release}: #{exception.message}"
		end
	end
end
