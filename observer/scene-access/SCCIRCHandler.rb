require 'nil/irc'
require 'IRCHandler'

class SCCIRCHandler < IRCHandler
	attr_writer :http
	
	def onEntry
		data =
		{
			'announce' => 'yes',
			'invite' => 'invite'
		}
		@http.post('/irc.php', data)
		
		@console.output 'Trying to enter the announce channel'
	end
end
