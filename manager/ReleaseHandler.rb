require 'sequel'
require 'ReleaseData'

class ReleaseHandler
	def initialize(manager, configuration)
		databaseConfiguration = configuration.const_get(:Database)
		@database =
			Sequel.connect(
				adapter: databaseConfiguration.const_get(:Adapter),
				host: databaseConfiguration.const_get(:Host),
				user: databaseConfiguration.const_get(:User),
				password: databaseConfiguration.const_get(:Password),
				database: databaseConfiguration.const_get(:Database)
			)
			
		#Sequel::DatabaseConnectionError
		
		@http = manager.http
	end
	
	def processMessage(release, url)
		prefix = 'http://'
		return if url.size <= prefix.size
		offset = url.find('/', prefix.size)
		path = url[offset..-1]
		data = @http.get(path)
		if data == nil
			puts "Error: Failed to retrieve URL #{url} (path: #{path}, release; #{release})"
			return
		end
		begin
			releaseData = ReleaseData.new data
			
		rescue StandardException => exception
			puts "Error: Unable to parse data from release #{release} at #{url}: #{exception}"
		end
	end
end
