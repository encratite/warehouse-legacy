require 'sequel'
require 'pg'
require 'ReleaseData'

require 'nil/file'

class ReleaseHandler
	def initialize(manager, configuration)
		@http = manager.http
		@torrentPath = configuration::Torrent::Path
		@sizeLimit = configuration::Torrent::SizeLimit
		
		begin
			database = configuration::Database
			
			@database =
				Sequel.connect(
					adapter: database::Adapter,
					host: database::Host,
					user: database::User,
					password: database::Password,
					database: database::Database
				)
			
		#Sequel::DatabaseConnectionError
		
			#run an early test to see if the DBMS is accessible?
			@database[:user_data]
		rescue Sequel::DatabaseConnectionError => exception
			databaseDown exception
		end
	end
	
	def databaseDown(exception)
		puts "The DBMS appears to be down: #{exception.message}"
		exit
	end
	
	def isReleaseOfInterest(release)
		result = @database['select count(*) from user_data where ? ~ name', release]
		#return result.first.values.first > 0
		return true
	end
	
	def insertData(releaseData)
		begin
			insertData = releaseData.getData
			@database[:release].insert(*insertData)
		rescue	Sequel::DatabaseError => exception
			puts "DBMS exception: #{exception.message}"
		end
	end
	
	def processMessage(release, url)
		prefix = 'http://'
		return if url.size <= prefix.size
		offset = url.index('/', prefix.size)
		path = url[offset..-1]
		data = @http.get(path)
		if data == nil
			puts "Error: Failed to retrieve URL #{url} (path: #{path}, release; #{release})"
			return
		end
		begin
			releaseData = ReleaseData.new(data)
			isOfInterest = false
			@database.transaction do
				insertData(releaseData)
				isOfInterest = isReleaseOfInterest(release)
			end
			if isOfInterest
				puts "Discovered a release of interest: #{release}"
				if releaseData.size > @sizeLimit
					puts "Unluckily the size of this release exceeds the limit (#{releaseData.size} > #{@sizeLimit})"
					return
				end
				path = releaseData.path
				torrentMatch = /\/([^\/]+\.torrent)/.match(path)
				if torrentMatch == nil
					puts "Failed to retrieve the torrent name from the torrent path: #{path}"
					return
				end
				torrent = torrentMatch[1]
				puts "Downloading #{path}"
				torrentData = @http.get(path)
				torrentPath = File.expand_path(torrent, @torrentPath)
				Nil.writeFile(torrentPath, torrentData)
				puts "Downloaded #{path} to #{torrentPath}"
			else
				puts "#{release} is not a release of interest"
			end
		rescue Sequel::DatabaseConnectionError => exception
			databaseDown exception
		rescue ReleaseData::Error => exception
			puts "Error: Unable to parse data from release #{release} at #{url}: #{exception.message}"
		end
	end
end
