require 'shared/ReleaseSite'

class SceneAccessSite < ReleaseSite
	def initialise(siteData, torrentData)
		super(siteData, torrentData)
		@irc.httpHandler = @httpHandler
	end
end
