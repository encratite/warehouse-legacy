require 'shared/HTTPHandler'
require 'shared/ConsoleHandler'
require 'shared/ReleaseHandler'
require 'ReleaseObserver'

require 'TVIRCHandler'
require 'TVReleaseData'

class TVObserver < ReleaseObserver
	def siteInitialisation
		createObjects(@configuration::TorrentVault, TVReleaseData, TVIRCHandler)
		ircData = @configuration::TorrentVault::IRC
		@irc.inviteBot = ircData::InviteBot
		@irc.inviteCode = ircData::InviteCode
	end
end
