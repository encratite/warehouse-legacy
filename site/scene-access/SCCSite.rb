require 'shared/ReleaseSite'

require 'SCCIRCHandler'
require 'SCCReleaseData'

class SCCSite < ReleaseSite
	def initialise(siteData, torrentData)
		super(siteData, torrentData)
		@irc.httpHandler = @httpHandler
	end
end
