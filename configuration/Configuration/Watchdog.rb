module Configuration
	module Watchdog
		Programs =
		[
			['Cleaner', 'ruby cleaner/main.rb'],
			['Notification server', 'ruby notification/runServer.rb'],
			['SceneAccess observer', 'ruby observer/SceneAccess.rb'],
			['TorrentVault observer', 'ruby observer/TorrentVault.rb'],
			['TorrentLeech observer', 'ruby observer/TorrentLeech.rb'],
			#this service is no longer used and has been superseded by the JSON protocol within the notification protocol
			#['JSON RPC server', 'thin.*rpc-server/server.ru'],
		]
		
		#delay between checks in seconds
		Delay = 1.0
		
		Log = 'watchdog.log'
	end
end
