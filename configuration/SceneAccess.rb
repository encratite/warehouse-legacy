require 'site/scene-access/SceneAccessReleaseData'
require 'site/scene-access/SceneAccessIRCHandler'

require 'secret/SceneAccess'

module SceneAccessConfiguration
	module HTTP
		Server = 'scene-access.org'
		#Cookies are secret
	end
	
	module IRC
		Server = 'irc.scene-access.org'
		Port = 6667
		#Nick is secret
		Channels = ['#scc-announce']
		Bots =
		[
			{nick: 'SCC', host: 'csops.scene-access.org'}
		]
		
		module Regexp
			Release = /-> ([^ ]+) \(Uploaded/
			URL = /(http:\/\/[^\)]+)\)/
		end
	end
	
	Log = 'scene-access.log'
	Table = :sceneaccess_data
	Name = 'SceneAccess'
	Abbreviation = 'SCC'
	
	ReleaseDataClass = SceneAccessReleaseData
	IRCHandlerClass = SceneAccessIRCHandler
end
