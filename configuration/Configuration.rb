require 'nil/environment'
require 'nil/file'

module Configuration
	module SQLDatabase
		Adapter = 'postgres'
		Host = '127.0.0.1'
		User = 'void'
		Password = ''
		SQLDatabase = 'warehouse'
	end
	
	module Torrent
		module Path
			UserBind = '/all'
			Filtered = 'filtered'
			Own = 'own'
			Manual = 'manual'
			Torrent = '/home/void/torrent/torrent'
			Download = '/home/void/torrent/download'
			DownloadDone = '/home/void/torrent/complete'
			User = '/home/warehouse/user'
		end
			
		Gigabyte = 2**30
		SizeLimit = 25 * Gigabyte
		
		module Cleaner
			FreeSpaceMinimum = 10 * Gigabyte
			#delay in seconds
			CheckDelay = 120
			UnseededTorrentRemovalDelay = 3600
			Log = 'cleaner.log'
		end
		
		module User
			ShellGroup = 'warehouse-shell'
			SFTPGroup = 'warehouse-sftp'
		end
		
		module HTTP
			BrowseDelay = 15 * 60
			DownloadDelay = 5
			ParserTimeout = 10
		end
		
		NIC = 'eth0'
	end
	
	module Shell
		FilterLengthMaximum = 128
		FilterCountMaximum = 500
		SearchResultMaximum = 100
		SSHKeyMaximum = 2048
		CommandLogCountMaximum = 100
	end
	
	module Logging
		Path = 'log'
		CategoriserLog = Nil.joinPaths(Path, 'categoriser.log')
	end
	
	module JSONRPCServer
		SessionCookie = 'session'
		Log = 'rpc.log'
	end
	
	module XMLRPC
		Host = '127.0.0.1'
		Port = 80
		Path = '/rtorrent'
	end
	
	module API
		ChangeOwnershipPath = '/bin/change-ownership'
	end
	
	module Notification
		#address unused by TCPServer?
		Address = '0.0.0.0'
		Port = 43841
		Socket =
			Nil.getHostname == 'perelman' ?
			'/home/void/socket' :
			'/home/void/code/warehouse/notification-server/socket/socket'
		
		module TLS
			CertificateAuthority = '/etc/warehouse/keys/certificate-authority.crt'
			ServerCertificate = '/etc/warehouse/keys/server.crt'
			ServerKey = '/etc/warehouse/keys/server.key'
		end
	end
end
