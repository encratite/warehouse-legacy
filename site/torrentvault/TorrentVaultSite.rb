require 'shared/html/IRCReleaseSite'
require 'configuration/TorrentVault'

class TorrentVaultSite < IRCReleaseSite
	def initialize(siteData, torrentData, database)
		super(siteData, torrentData, database)
		ircData = siteData::IRC
		@ircHandler.inviteBot = ircData::InviteBot
		@ircHandler.inviteCode = ircData::InviteCode
	end
end
