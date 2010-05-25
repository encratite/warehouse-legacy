require 'json/JSONObject'

class SiteStatistics
	attr_reader :releaseCount, :totalSize
	
	def initialize(releaseCount, totalSize)
		@releaseCount = releaseCount
		@totalSize = totalSize
	end
end
