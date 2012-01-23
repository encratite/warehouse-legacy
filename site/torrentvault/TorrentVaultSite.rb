require 'shared/irc/IRCReleaseSite'
require 'configuration/TorrentVault'
require 'site/torrentvault/TorrentVaultHTTP'

class TorrentVaultSite < IRCReleaseSite
  def initialize(siteData, torrentData, connections, configuration)
    super(siteData, torrentData, connections, configuration)
    ircData = siteData::IRC
    @ircHandler.inviteBot = ircData::InviteBot
    @ircHandler.inviteCode = ircData::InviteCode
    @ircHandler.password = ircData::Password
    @httpHandler = TorrentVaultHTTP.new(siteData)
    @releaseHandler.httpHandler = @httpHandler
  end
end
