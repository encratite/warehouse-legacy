require 'nil/irc'
require 'shared/irc/IRCHandler'

class SceneAccessIRCHandler < IRCHandler
  attr_writer :httpHandler

  def onEntry
    data = {
      'announce' => 'yes',
      #'pre' => 'yes',
      #'sceneaccess' => 'yes',
      'submit.x' => '28',
      'submit.y' => '12',
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
