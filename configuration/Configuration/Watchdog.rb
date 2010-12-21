module Configuration
  module Watchdog
    Programs =
      [
       ['RTorrent', 'rtorrent'],
       ['Cleaner', 'ruby cleaner/main.rb'],
       ['Notification server', 'ruby notification/runServer.rb'],
       ['SceneAccess observer', 'ruby observer/SceneAccess.rb'],
       ['TorrentVault observer', 'ruby observer/TorrentVault.rb'],
       ['TorrentLeech observer', 'ruby observer/TorrentLeech.rb'],
       #this service is no longer used and has been superseded by the JSON protocol within the notification protocol
       #['JSON RPC server', 'thin.*rpc-server/server.ru'],
      ]

    #delay between checks in seconds
    Delay = 5.0

    #time in seconds until an observer is being reported as inactive if no new releases are detected
    GracePeriod = 24 * 60 * 60

    #name of the log file
    Log = 'watchdog.log'
  end
end
