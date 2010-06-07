require 'shared/irc/IRCReleaseSite'
require 'configuration/TorrentVault'

class TorrentVaultSite < IRCReleaseSite
	def initialize(siteData, torrentData, connections)
		super(siteData, torrentData, connections)
		ircData = siteData::IRC
		@ircHandler.inviteBot = ircData::InviteBot
		@ircHandler.inviteCode = ircData::InviteCode
	end
end
