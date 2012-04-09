require 'nil/irc'

require 'shared/irc/IRCHandler'

class TorrentVaultIRCHandler < IRCHandler
  attr_writer :inviteBot, :inviteCode, :password

  def initialize(site)
    super(site)
    @irc.onNotice = method(:onNotice)
  end

  def onEntry
    output 'Trying to enter the announce channels'
    @irc.sendMessage('NickServ', "identify #{@password}")
    @irc.sendMessage(@inviteBot, "login #{@irc.nick} #{@inviteCode}")
  end

  def joinAnnounceChannels
    @releaseChannels.each do |channel|
      output "Joining announce channel #{channel}"
      @irc.joinChannel(channel)
    end
  end

  def onNotice(user, text)
    if user.nick == @inviteBot && text.index('Welcome') != nil
      joinAnnounceChannels
    end
  end
end
