require 'nil/irc'
require 'IRCHandler'

class TVIRCHandler < IRCHandler
	attr_writer :inviteBot, :inviteCode
	
	def onEntry
		@console.output 'Trying to enter the announce channels'
		@irc.sendMessage(@inviteBot, @inviteCode)
	end
end
