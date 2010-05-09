require 'nil/irc'
require 'IRCHandler'

class TVIRCHandler < IRCHandler
	attr_writer :inviteBot, :inviteCode
	
	def initialize(data, releaseHandler)
		super(data, releaseHandler)
		@irc.onInvite = method(:onInvite)
	end
	
	def onEntry
		output 'Trying to enter the announce channels'
		@irc.sendMessage(@inviteBot, "invite #{@irc.nick} #{@inviteCode}")
	end
	
	def onInvite(user, channel)
		if user.nick == @inviteBot && @releaseChannels.include?(channel)
			output "Joining announce channel #{channel}"
			@irc.joinChannel(channel)
		end
	end
	
	def output(message)
		@console.output(message)
	end
end
