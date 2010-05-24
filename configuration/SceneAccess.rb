require 'site/scene-access/SceneAccessReleaseData'
require 'site/scene-access/SceneAccessIRCHandler'

require 'secret/SceneAccess'

module SceneAccessConfiguration
	module HTTP
		Server = 'sceneaccess.org'
		#Cookies are secret
	end
	
	module IRC
		Server = 'irc.sceneaccess.org'
		Port = 6667
		#Nick is secret
		Channels = ['#scc-announce']
		Bots =
		[
			{nick: 'SCC', host: 'csops.sceneaccess.org'}
		]
		
		module Regexp
			Release = /-> ([^ ]+) \(Uploaded/
			URL = /(http:\/\/[^\)]+)\)/
		end
	end
	
	Log = 'sceneaccess.log'
	Table = :scene_access_data
	Name = 'SceneAccess'
	Abbreviation = 'SCC'
	
	ReleaseDataClass = SceneAccessReleaseData
	IRCHandlerClass = SceneAccessIRCHandler
end
