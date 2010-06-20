require 'etc'
require 'nil/file'

module Configuration
	module User
		WarehouseUser = 'void'
		ShellGroup = 'warehouse-shell'
		SFTPGroup = 'warehouse-sftp'
		
		def self.getWarehouseHome
			begin
				passwordData = Etc.getpwnam(WarehouseUser)
				return passwordData.dir
			rescue ArgumentError
				#user could not be found
				return nil
			end
		end
		
		def self.getPath(path)
			#just return nil for now - useful for running the initial setup because the home is not available at that time yet since the user might not exist
			base = self.getWarehouseHome
			return nil if base == nil
			return Nil.joinPaths(base, path)
		end
	end
end
