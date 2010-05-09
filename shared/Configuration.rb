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
			
			module Bot
				Nick = 'SCC'
				Host = 'csops.sceneaccess.org'
			end
			
			module Regexp
				Release = /-> ([^ ]+) \(Uploaded/
				URL = /(http:\/\/[^\)]+)\)/
			end
		end
		
		Log = 'scene-access.log'
		Table = :scene_access_data
		Name = 'SceneAccess'
		Abbreviation = 'SCC'
	end
	
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
			InviteBot = 'TorrentVault'
			InviteCode = 'a506b1d15d1dd487f68065318ff95f0f'
			
			module Bot
				Nick = 'InfoVault'
				Host = 'services.torrentvault'
			end
			
			module Regexp
				Release = /NEW.+-> (.+) by [^ ]+ \[/
				URL = /(https:\/\/.+?) \]/
			end
		end
		
		Log = 'torrentvault.log'
		Table = :torrentvault_data
		Name = 'TorrentVault'
		Abbreviation = 'TV'
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
