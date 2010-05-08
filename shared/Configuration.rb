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
		module HTTP
			Server = 'sceneaccess.org'
			Cookies =
			[
				'uid' => '953675',
				'pass' => 'ab31c2bdf48e5e9d60d19b7f40cf0de0'
			]
		end
		
		module IRC
			Server = 'irc.sceneaccess.org'
			Nick = 'malleruet'
			Channels = ['#scc-announce']
			
			module Bot
				Nick = 'SCC'
				Host = 'csops.sceneaccess.org'
			end
			
			module Regexp
				Release = /\-\> ([^ ]+) \(Uploaded/
				URL = /(http\:\/\/[^\)]+)\)/
			end
		end
		
		Log = 'scene-access.log'
	end
	
	module Torrent
		def self.pick(unix, windows)
			return Nil.getOS == :windows ? windows : unix
		end
		
		module LinuxPath
			UserBind = '/all'
			Filtered = 'filtered'
			Own = 'own'
			Manual = 'manual'
			Torrent = '/home/void/torrent/torrent'
			Download = '/home/void/torrent/download'
			DownloadDone = '/home/void/torrent/complete'
			User = '/home/warehouse/user'
		end
		
		module WindowsPath
			UserBind = 'G:\Warehouse\void\all'
			Filtered = 'filtered'
			Own = 'own'
			Manual = 'manual'
			Torrent = 'G:\Torrent'
			Download = 'G:\BTTemp'
			DownloadDone = 'G:\BTTemp'
			User = 'G:\Warehouse'
		end
		
		Path = self.pick(LinuxPath, WindowsPath)
			
		Gigabyte = 2**30
		SizeLimit = 25 * Gigabyte
		
		module Cleaner
			FreeSpaceMinimum = 10 * Gigabyte
			#delay in seconds
			CheckDelay = 30
		end
		
		module User
			ShellGroup = 'warehouse-shell'
			SFTPGroup = 'warehouse-sftp'
		end
		
		NIC = 'eth0'
	end
	
	module Shell
		FilterLengthMaximum = 128
		FilterCountMaximum = 500
		SearchResultMaximum = 100
		SSHKeyMaximum = 2048
	end
	
	module Logging
		Path = '../log/'
		CategoriserLog = Path + 'categoriser.log'
		SitePath = '../../log/'
	end
end
