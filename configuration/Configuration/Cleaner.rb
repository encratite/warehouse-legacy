module Configuration
	module Torrent
		module Cleaner
			FreeSpaceMinimum = 10 * Gigabyte
			#delay in seconds
			CheckDelay = 120
			UnseededTorrentRemovalDelay = 3600
			#seconds before an entry in the database queue cache is removed
			QueueEntryAgeMaximum = 7 * 24 * 60 * 60
			Log = 'cleaner.log'
		end
	end
end
