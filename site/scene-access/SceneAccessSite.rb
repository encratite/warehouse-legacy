require 'shared/ReleaseSite'

require 'SceneAccessIRCHandler'
require 'shared/SceneAccessReleaseData'

class SceneAccessSite < ReleaseSite
	def initialise(siteData, torrentData)
		super(siteData, torrentData)
		@irc.httpHandler = @httpHandler
	end
end
