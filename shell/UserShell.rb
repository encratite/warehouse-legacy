require 'nil/string'
require 'nil/file'

require 'fileutils'

class UserShell
	Commands =
	[
		['?', 'prints this help', :commandHelp],
		['help', 'prints this help', :commandHelp],
		['add <regexp>', 'add a new release filter to your account (case insensitive)', :commandAddFilterInsensitive],
		['add-cs <regexp>', 'the case sensitive version of the add command', :commandAddFilterSensitive],
		['list', 'retrieve a list of your filters', :commandListFilters],
		['delete <index 1> <...>', 'removes one or several filters which are identified by their numeric index', :commandDeleteFilter],
		['clear', 'remove all your release filters', :commandClearFilters],
		['database', 'get statistics on the database', :commandDatabase],
		['search <regexp>', 'search the database for release names matching the regular expression (case insensitive)', :commandSearchInsensitive],
		['search-cs <regexp>', 'the case sensitive version of the search command', :commandSearchSensitive],
		['download <ID or name>', 'start the download of a release', :commandDownload],
		['status', 'retrieve the status of downloads in progress', :commandStatus],
		['cancel', 'cancel a download', :commandCancel],
		['permissions', 'view your permissions/limits', :commandPermissions],
		['exit', 'terminate your session', :commandExit],
		['quit', 'terminate your session', :commandExit],
		['ssh <SSH key data>', 'set the SSH key in your authorized_keys to authenticate without a password prompt', :commandSSH]
	]
	
	def initialize(configuration, database, user, http)
		@filterLengthMaximum = configuration::Shell::FilterLengthMaximum
		@filterCountMaximum = configuration::Shell::FilterCountMaximum
		@searchResultMaximum = configuration::Shell::SearchResultMaximum
		@sshKeyMaximum = configuration::Shell::SSHKeyMaximum
		@group = configuration::Shell::Group
		@releaseSizeLimit = configuration::Torrent::SizeLimit
		@database = database
		@user = user
		@releases = @database[:release]
		@filters = @database[:user_release_filter]
		@http = http
		@torrentPath = configuration::Torrent::Path
	end
	
	def run
		prefix = @user.shellPrefix
		while true
			begin
				print prefix
				line = STDIN.readline
				tokens = line.split(' ')
				next if tokens.empty?
				command = tokens[0]
				@arguments = tokens[1..-1]
				@argument = line[command.size..-1].strip
				
				validCommand = false
				
				begin
					Commands.each do |arguments, description, symbol|
						commandNames = arguments.split(' ')[0].split('/')
						next if !commandNames.include?(command)
						method(symbol).call
						validCommand = true
						break
					end
				rescue RegexpError => exception
					puts "You have entered an invalid regular expression: #{exception.message}"
					next
				end
				
				puts 'Invalid command.' if !validCommand
			rescue Interrupt
				puts 'Interrupt.'
				exit
			rescue EOFError
				puts 'Terminating.'
				exit
			end
		end
	end
	
	def commandHelp
		puts 'List of available commands:'
		sortedCommands = Commands.sort { |a, b| a[0] <=> b[0] }
		names = sortedCommands.map { |x| x[0] }
		maximum = 0
		names.each do |names|
			maximum = names.size if names.size > maximum
		end
		sortedCommands.each do |name, description, symbol|
			name += ' ' * (maximum - name.size)
			puts "#{name} - #{description}"
		end
	end
	
	def commandAddFilter(caseSensitive)
		if @argument.empty?
			puts 'Please specify a filter to add.'
			return
		end
		filter = @argument
		if filter.size > @filterLengthMaximum
			puts "Your filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		if @filters.where(user_id: @user.id).count > @filterCountMaximum
			puts "You have too many filters already (#{filterCountMaximum})."
			return
		end
		@filters.insert(user_id: @user.id, filter: filter, is_case_sensitive: caseSensitive)
		puts "Your filter has been added."
	end
	
	def commandAddFilterInsensitive
		commandAddFilter false
	end
	
	def commandAddFilterSensitive
		commandAddFilter true
	end
	
	def commandListFilters
		filters = @filters.where(user_id: @user.id).select(:filter, :is_case_sensitive)
		if filters.empty?
			puts 'You currently have no filters.'
			return
		end
		puts 'This is a list of your filters:'
		counter = 1
		filters.each do |filter|
			info = "#{counter}. #{filter[:filter]}"
			if filter[:is_case_sensitive]
				puts "#{info} [case sensitive]"
			else
				puts info
			end
			counter += 1
		end
	end
	
	def commandDeleteFilter
		if @arguments.empty?
			puts 'Please specify the index of a filter to delete.'
			return
		end
		
		@arguments.each do |index|
			if !index.isNumber
				puts "Invalid argument: #{index}"
				return
			end
		end
		
		@database.transaction do
			indices = @arguments.map { |index| index.to_i }
			ids = []
			
			indices.each do |index|
				if index <= 0
					puts "Index too low: #{index}"
					return
				end
				result = @filters.where(user_id: @user.id).select(:id).limit(1, index - 1)
				if result.empty?
					puts "Invalid index: #{index}"
					return
				end
				ids << result.first[:id]
			end
			
			ids.each { |id| @filters.where(id: id).delete }
		end
		
		if @arguments.size == 1
			puts 'The filter has been removed.'
		else
			puts 'The filters have been removed.'
		end
	end
	
	def commandClearFilters
		@filters.where(user_id: @user.id).delete
		puts 'All your filters have been removed.'
	end
	
	def commandDatabase
		puts "Number of releases in the database: #{@releases.count}"
		sizeString = Nil.getSizeString(@releases.sum(:release_size))
		puts "Size of releases available on demand: #{sizeString}"
	end
	
	def commandSearch(caseSensitive)
		if @argument.empty?
			puts "Specify a regular expression to look for."
			return
		end
		
		if @argument.size > @filterLengthMaximum
			puts "Your search filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		
		#results = @releases.filter(name: Regexp.new(@argument))
		#results = results.select(:site_id, :section_name, :name, :release_date, :release_size).reverse_order(:site_id)
		#results = results.limit(@searchResultMaximum)
		
		operator =
			caseSensitive ?
			'~' :
			'~*'
		
		results = @database["select site_id, section_name, name, release_date, release_size from release where name #{operator} ? order by site_id desc limit ?", @argument, @searchResultMaximum]
		
		if results.empty?
			puts 'Your search yielded no results.'
			return
		end
		
		results.each do |result|
			sizeString = Nil.getSizeString(result[:release_size])
			timestamp = result[:release_date].utc.to_s
			puts "[#{result[:site_id]}] [#{result[:section_name]}] #{result[:name]} (#{sizeString}, #{timestamp})"
		end
		
		if results.count > 5
			puts "Found #{results.count} results."
		end
	end
	
	def commandSearchInsensitive
		commandSearch(false)
	end
	
	def commandSearchSensitive
		commandSearch(true)
	end
	
	def commandDownload
		if @argument.empty?
			puts "You have not specified a release to download."
			return
		end
		
		if @argument.isNumber
			id = @argument.to_i
			result = @releases.where(site_id: id)
		else
			result = @releases.filter(name: Regexp.new(@argument))
		end
		result = result.select(:name, :torrent_path, :release_size)
		if result.empty?
			puts 'Unable to find the release you have specified.'
			return
		end
		result = result.first
		
		size = result[:release_size]
		if size > @releaseSizeLimit
			sizeString = Nil.getSizeString size
			sizeLimitString = Nil.getSizeString @releaseSizeLimit
			
			puts "This release has a size of #{sizeString} which exceeds the current limit of #{sizeLimitString}"
			return
		end
		
		puts "Attempting to queue release #{result[:name]}"
		
		httpPath = result[:torrent_path]
		
		torrentMatch = /\/([^\/]+\.torrent)/.match(httpPath)
		if torrentMatch == nil
			puts 'Database error: Unable to queue release'
			return
		end
		torrent = torrentMatch[1]
		
		torrentPath = File.expand_path(torrent, @torrentPath)
		
		if Nil.readFile(torrentPath) != nil
			puts 'This release had already been queued, overwriting it'
			#return
		end
		
		data = @http.get(httpPath)
		if data == nil
			puts 'HTTP error: Unable to queue release'
			return
		end
		
		Nil.writeFile(torrentPath, data)
		
		puts 'Success!'
	end
	
	def commandStatus
		puts 'STATUS!'
		puts '... just kidding, not implemented yet.'
	end
	
	def commandCancel
		puts 'Yet to be implemented, sorry.'
	end
	
	def commandExit
		puts 'See you.'
		#sleep 1
		exit
	end

	def commandPermissions
		if @user.isAdministrator
			userLevel = 'Administrator'
		else
			userLevel = 'Regular user'
		end
		puts "User level: #{userLevel}"
		sizeLimitString = Nil.getSizeString @releaseSizeLimit
		puts "Size limit per release: #{sizeLimitString}"
		puts "Search result limit: #{@searchResultMaximum}"
	end
	
	def commandSSH
		if @argument.size >= @sshKeyMaximum
			puts "Your SSH data exceeds the maximal length of #{@sshKeyMaximum}."
			return
		end
		if @arguments.size != 3
			puts "Your SSH data does not fit the following pattern: ssh-(rsa|dsa) data comment"
			return
		end
		type = @arguments[0]
		if !['ssh-rsa', 'ssh-dsa'].include?(type)
			puts "Unknown SSH key type: #{type}"
			return
		end
		sshDirectory = '~/.ssh'
		begin
			FileUtils.mkdir(sshDirectory)
		rescue Errno::EEXIST
		rescue Errno::ENOENT
			puts 'Unable to create the directory'
			return
		end
		permission = 0700
		FileUtils.chmod(permission, sshDirectory)
		keysFile = "#{sshDirectory}/authorized_keys"
		Nil.writeFile(keysFile, @argument)
		FileUtils.chmod(permission, keysFile)
		puts "Your SSH key has been changed."
	end
end
