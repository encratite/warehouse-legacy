class WatchedSite
	attr_reader :name, :dataset
	attr_accessor :lastReleaseTime, :isLate
	
	def initialize(site)
		@name = site.name
		@dataset = site.dataset
		@lastReleaseTime = nil
		@isLate = false
	end
end
