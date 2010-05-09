require 'site/scene-access/SceneAccessReleaseData'
require 'site/scene-access/SceneAccessIRCHandler'

module SceneAccessConfiguration
	module HTTP
		Server = 'sceneaccess.org'
		Cookies =
		{
			'uid' => '953675',
			'pass' => 'ab31c2bdf48e5e9d60d19b7f40cf0de0'
		}
	end
	
	module IRC
		Server = 'irc.sceneaccess.org'
		Port = 6667
		Nick = 'malleruet'
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
	
	Log = 'scene-access.log'
	Table = :scene_access_data
	Name = 'SceneAccess'
	Abbreviation = 'SCC'
	
	ReleaseDataClass = SceneAccessReleaseData
	IRCHandlerClass = SceneAccessIRCHandler
end
