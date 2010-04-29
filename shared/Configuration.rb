require 'nil/environment'

module Configuration
	module Cookie
		UId = '953675'
		Pass = 'ab31c2bdf48e5e9d60d19b7f40cf0de0'
	end
	
	module IRC
		Server = 'irc.sceneaccess.org'
		Nick = 'malleruet'
	end
	
	module Database
		Adapter = 'postgres'
		Host = '127.0.0.1'
		User = 'void'
		Password = ''
		Database = 'scene_access'
	end
	
	module ReleaseChannel
		Channel = '#scc-announce'
		Nick = 'SCC'
		Host = 'csops.sceneaccess.org'
		
		module Regexp
			Release = /\-\> ([^ ]+) \(Uploaded/
			URL = /(http\:\/\/[^\)]+)\)/
		end
	end
	
	module Torrent
		Path =
			Nil.getOS === :windows ?
			'G:\\Torrent' :
			'/home/void/torrent/torrent'
			
		SizeLimit = 10 * (2**30)
		#SizeLimit = 2**10
	end
	
	module Shell
		FilterLengthMaximum = 128
		FilterCountMaximum = 500
		SearchResultMaximum = 100
	end
end
