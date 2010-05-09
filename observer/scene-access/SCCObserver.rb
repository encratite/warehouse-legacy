require 'HTTPHandler'
require 'ConsoleHandler'
require 'ReleaseHandler'
require 'ReleaseObserver'

require 'SCCIRCHandler'
require 'SCCReleaseData'

class SCCObserver < ReleaseObserver
	def siteInitialisation
		createObjects(@configuration::SceneAccess, SCCReleaseData, SCCIRCHandler)
		@irc.http = @http
	end
end
