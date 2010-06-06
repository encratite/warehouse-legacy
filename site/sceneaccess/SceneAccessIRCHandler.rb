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
		@httpHandler.post('/irc.php', data)
	end
end
