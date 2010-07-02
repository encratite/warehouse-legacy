module Configuration
	module Watchdog
		Programs =
		[
			['Cleaner', 'ruby cleaner/main.rb'],
			['Notification server', 'ruby notification/runServer.rb'],
			['SceneAccess observer', 'ruby observer/SceneAccess.rb'],
			['TorrentVault observer', 'ruby observer/TorrentVault.rb'],
			['TorrentLeech observer', 'ruby observer/TorrentLeech.rb'],
			['JSON RPC server', 'thin.*rpc-server/server.ru'],
		]
		
		#delay between checks in seconds
		Delay = 1.0
	end
end
