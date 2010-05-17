require 'nil/file'

require 'shell/SearchResult'

require 'shared/sites'

[
	'commandDescriptions'
	'commands'
	'download'
	'regexp'
	'completion'
	'reader'
	'output'
].each { |x| require "shell/UserShell/#{x}" }

class HTTPError < StandardError
end

class UserShell
	def initialize(configuration, database, user)
		@configuration = configuration
		
		@filterLengthMaximum = configuration::Shell::FilterLengthMaximum
		@filterCountMaximum = configuration::Shell::FilterCountMaximum
		@searchResultMaximum = configuration::Shell::SearchResultMaximum
		
		@sshKeyMaximum = configuration::Shell::SSHKeyMaximum
		
		@releaseSizeLimit = configuration::Torrent::SizeLimit
		
		@database = database
		@user = user
		
		@torrentPath = configuration::Torrent::Path::Torrent
		@userPath = Nil.joinPaths(configuration::Torrent::Path::User, @user.name)
		@filteredPath = Nil.joinPaths(@userPath, configuration::Torrent::Path::Filtered)
		@nic = configuration::Torrent::NIC
		
		@filters = @database[:user_release_filter]
		
		@sites = getReleaseSites
		
		@commands = getCommandStrings
	end
	
	def convertFilterIndices(input)
		input.each do |index|
			if !index.isNumber
				error "Invalid argument: #{index}"
				return
			end
		end
		
		indices = input.map { |index| index.to_i }
		ids = []
		
		indices.each do |index|
			if index <= 0
				error "Index too low: #{index}"
				return
			end
			result = @filters.where(user_id: @user.id).order(:id).select(:id).limit(1, index - 1)
			if result.empty?
				error "Invalid index: #{index}"
				return
			end
			ids << result.first[:id]
		end
		
		return ids
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
end
