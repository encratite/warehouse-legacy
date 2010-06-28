module Configuration
	module Torrent
		module Path
			UserBind = '/all'
			Filtered = 'filtered'
			Own = 'own'
			Manual = 'manual'
			
			User = '/home/warehouse/user'
			
			#need separate path constants for the setup script - otherwise they would be nil
			module RelativePaths
				Torrent = 'torrent/torrent'
				Download = 'torrent/download'
				DownloadDone = 'torrent/complete'
			end
			
			def self.setPaths
				RelativePaths.constants.each do |symbol|
					value = RelativePaths.const_get(symbol)
					value = Configuration::User.getPath(value)
					const_set(symbol, value)
				end
			end
			
			self.setPaths
		end
	end
end
