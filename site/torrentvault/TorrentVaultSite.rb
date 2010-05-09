require 'shared/ReleaseSite'
require 'configuration/TorrentVault'

class TorrentVaultSite < ReleaseSite
	def initialize(siteData, torrentData)
		super(siteData, torrentData)
		ircData = siteData::IRC
		@ircHandler.inviteBot = ircData::InviteBot
		@ircHandler.inviteCode = ircData::InviteCode
	end
end
