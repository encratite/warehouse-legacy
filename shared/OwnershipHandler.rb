class OwnershipHandler
	def initialize(configuration)
		@binary = configuration::ChangeOwnershipPath
	end
	
	def changeOwnership(user, path)
		commandLine = "#{@binary} #{user} #{path}"
		message = `#{commandLine}`
		returnCode = $?.to_i
		if returnCode != 0
			raise "Failed to transfer ownership of path #{path} to #{user}: #{message}"
		end
		return nil
	end
end
