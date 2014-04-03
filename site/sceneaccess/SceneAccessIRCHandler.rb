require 'nil/irc'
require 'shared/irc/IRCHandler'

class SceneAccessIRCHandler < IRCHandler
  attr_writer :httpHandler, :password
  
  def initialize(site)
    super(site)
    @irc.onNotice = method(:onNotice)
  end

  def onEntry
	@irc.sendMessage('NickServ', "identify #{@password}")
  end
  
  def onNotice(user, text)
    if user.nick == 'NickServ' && text.index('Password accepted') != nil
      requestInvitation
    end
  end
  
  def requestInvitation
	data = {
      'announce' => 'yes',
      #'pre' => 'yes',
      #'sceneaccess' => 'yes',
      'submit.x' => '36',
      'submit.y' => '5',
    }
    output 'Trying to enter the announce channel'
    reply = @httpHandler.post('/irc.php', data)
    if reply == nil
      output 'Failed to perform the HTTP post required! Reconnecting...'
      #Recursion? Bad?
      @irc.reconnect
    end
  end
end
