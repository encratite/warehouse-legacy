[
	'commandDescriptions',
	'commands',
	'download',
	'regexp',
	'completion',
	'reader',
	'output',
	'administratorCommands',
	'torrentCommands',
].each { |x| require "shell/UserShell/#{x}" }

require 'shared/sites'

require 'user-api/UserAPI'

class UserShell
	def initialize(configuration, connections, user)
		@user = user
		
		@connections = connections
		@database = connections.sqlDatabase
		
		@commands = getCommandStrings
		@api = UserAPI.new(configuration, connections, user)
		@nic = configuration::Torrent::NIC
		
		@logs = @database[:user_command_log]
		
		@sites = getReleaseSites(connections)
	end
		
	def padEntries(input)
		maximum = 0
		input.each do |array|
			size = array[0].size
			maximum = size if size > maximum
		end
		output = input.map do |array|
			left = array[0]
			left = left + (' ' * (maximum - left.size))
			newArray = [left]
			newArray += array[1..-1]
			newArray
		end
		return output
	end
	
	def convertFilterIndexStrings(indexStrings)
		indexStrings.each do |index|
			if !index.isNumber
				error "Invalid argument: #{index}"
				return
			end
		end
		
		indices = indexStrings.map { |index| index.to_i }
		
		return indices
	end
end
