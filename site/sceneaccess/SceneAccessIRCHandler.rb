require 'nil/irc'
require 'shared/irc/IRCHandler'

class SceneAccessIRCHandler < IRCHandler
	attr_writer :httpHandler
	
	def onEntry
		data =
		{
			'announce' => 'yes',
			'invite' => 'invite'
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
