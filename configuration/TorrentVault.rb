require 'site/torrentvault/TVReleaseData'
require 'site/torrentvault/TVIRCHandler'

module TorrentVault
	module HTTP
		Server = 'torrentvault.org'
		Cookies =
		{
			'name' => 'test',
			'name' => 'test'
		}
	end
	
	module IRC
		Server = 'irc.torrentvault.org'
		Port = 9011
		Nick = 'assunamal'
		Channels = ['#tv', '#tv-spam']
		Bots =
		[
			{nick: 'InfoVault', host: 'services.torrentvault'}
		]
		
		InviteBot = 'TorrentVault'
		InviteCode = 'a506b1d15d1dd487f68065318ff95f0f'
		
		module Regexp
			Release = /NEW.+-> (.+) by [^ ]+ \[/
			URL = /(https:\/\/.+?) \]/
		end
	end
	
	Log = 'torrentvault.log'
	Table = :torrentvault_data
	Name = 'TorrentVault'
	Abbreviation = 'TV'
	
	ReleaseDataClass = TVReleaseData
	IRCHandlerClass = TVIRCHandler
end
