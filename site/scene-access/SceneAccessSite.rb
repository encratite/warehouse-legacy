require 'shared/ReleaseSite'

class SceneAccessSite < ReleaseSite
	def initialize(siteData, torrentData)
		super(siteData, torrentData)
		@ircHandler.httpHandler = @httpHandler
	end
end
