require 'shared/IRCReleaseSite'

class SceneAccessSite < IRCReleaseSite
	def initialize(siteData, torrentData)
		super(siteData, torrentData)
		@ircHandler.httpHandler = @httpHandler
	end
end
