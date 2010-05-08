require 'nil/irc'
require 'IRCHandler'

class SCCIRCHandler < IRCHandler
	def onEntry
		data =
		{
			'announce' => 'yes',
			'invite' => 'invite'
		}
		@http.post('/irc.php', data)
		
		@console.onEntry
	end
end
