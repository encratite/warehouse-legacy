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
		@console.output 'Trying to enter the announce channel'
		@http.post('/irc.php', data)
	end
end
