require 'shared/irc/IRCReleaseSite'
require 'configuration/TorrentVault'
require 'site/TorrentVault/TorrentVaultHTTP'

class TorrentVaultSite < IRCReleaseSite
  def initialize(siteData, torrentData, connections, configuration)
    super(siteData, torrentData, connections, configuration)
    ircData = siteData::IRC
    @ircHandler.inviteBot = ircData::InviteBot
    @ircHandler.inviteCode = ircData::InviteCode
    @httpHandler = TorrentVaultHTTP.new(siteData)
  end
end
