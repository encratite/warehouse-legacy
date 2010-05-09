require 'TorrentVaultObserver'
require 'configuration/Configuration'

observer = TorrentVaultObserver.new(Configuration)
observer.run
