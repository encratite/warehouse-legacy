require 'shared/HTTPHandler'
require 'shared/ConsoleHandler'
require 'shared/ReleaseHandler'
require 'ReleaseObserver'

require 'TorrentVaultIRCHandler'
require 'shared/TorrentVaultReleaseData'

class TorrentVaultObserver < ReleaseObserver
	def siteInitialisation
		createObjects(@configuration::TorrentVault, TorrentVaultReleaseData, TorrentVaultIRCHandler)
		ircData = @configuration::TorrentVault::IRC
		@irc.inviteBot = ircData::InviteBot
		@irc.inviteCode = ircData::InviteCode
	end
end
