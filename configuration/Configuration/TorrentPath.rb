module Configuration
	module Torrent
		module Path
			UserBind = '/all'
			Filtered = 'filtered'
			Own = 'own'
			Manual = 'manual'
			Torrent = User.getPath('torrent/torrent')
			Download = User.getPath('torrent/download')
			DownloadDone = User.getPath('torrent/complete')
			User = '/home/warehouse/user'
		end
	end
end
