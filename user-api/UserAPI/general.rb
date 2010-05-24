require 'user-api/SiteStatistics'

class UserAPI
	def getSiteStatistics(name)
		@sites.each do |site|
			next if site.name != name
			table = @database[site.table]
			releaseCount = table.count
			totalSize = table.sum(:release_size)
			output = SiteStatistics.new(releaseCount, totalSize)
			return output
		end
		return nil
	end
end
