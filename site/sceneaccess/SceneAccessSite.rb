require 'shared/irc/IRCReleaseSite'

class SceneAccessSite < IRCReleaseSite
	def initialize(siteData, torrentData, connections, configuration)
		super(siteData, torrentData, connections, configuration)
		@ircHandler.httpHandler = @httpHandler
	end
end
