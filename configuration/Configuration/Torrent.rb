module Configuration
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
			#seconds before an entry in the database queue cache is removed
			QueueEntryAgeMaximum = 7 * 24 * 60 * 60
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
end
