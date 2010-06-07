require 'shared/irc/IRCReleaseSite'

class SceneAccessSite < IRCReleaseSite
	def initialize(siteData, torrentData, connections)
		super(siteData, torrentData, connections)
		@ircHandler.httpHandler = @httpHandler
	end
end
