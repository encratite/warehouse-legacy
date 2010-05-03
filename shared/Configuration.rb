require 'nil/environment'

module Configuration
	module Database
		Adapter = 'postgres'
		Host = '127.0.0.1'
		User = 'void'
		Password = ''
		Database = 'warehouse'
	end
	
	module SceneAccess
		module Cookie
			UId = '953675'
			Pass = 'ab31c2bdf48e5e9d60d19b7f40cf0de0'
		end
		
		module IRC
			Server = 'irc.sceneaccess.org'
			Nick = 'malleruet'
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
	end
	
	module Torrent
		TorrentPath =
			Nil.getOS === :windows ?
			'G:\Torrent' :
			'/home/void/torrent/torrent'
			
		DownloadPath =
			Nil.getOS == :windows ?
			'G:\BTTemp' :
			'/home/void/torrent/complete'
			
		SizeLimit = 25 * (2**30)
	end
	
	module Shell
		FilterLengthMaximum = 128
		FilterCountMaximum = 500
		SearchResultMaximum = 100
		SSHKeyMaximum = 2048
	end
	
	module Logging
		ManagerLog = '../log/manager.log'
	end
end
