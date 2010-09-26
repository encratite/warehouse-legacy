require_relative 'site/torrentvault/TorrentVaultReleaseData'
require_relative 'site/torrentvault/TorrentVaultIRCHandler'

require_relative 'secret/TorrentVault'

module TorrentVaultConfiguration
	module HTTP
		Server = 'torrentvault.org'
		#Cookies are secret
	end
	
	module IRC
		Server = 'irc.torrentvault.org'
		Port = 9011
		#Nick is secret
		Channels = ['#tv', '#tv-spam']
		Bots =
		[
			{nick: 'InfoVault', host: 'services.torrentvault'}
		]
		
		InviteBot = 'TorrentVault'
		#InviteCode is secret
		
		module Regexp
			Release = /NEW.+-> (.+) by [^ ]+ \[/
			URL = /(https:\/\/.+?) \]/
		end
	end
	
	Log = 'torrentvault.log'
	Table = :torrentvault_data
	Name = 'TorrentVault'
	Abbreviation = 'TV'
	
	ReleaseDataClass = TorrentVaultReleaseData
	IRCHandlerClass = TorrentVaultIRCHandler
end
