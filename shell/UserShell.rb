require 'nil/string'
require 'nil/file'
require 'nil/console'

require 'fileutils'
require 'readline'

require 'ReleaseData'

class HTTPError < StandardError
end

class UserShell
	Commands =
	[
		['?', 'prints this help', :commandHelp],
		['help', 'prints this help', :commandHelp],
		['add <regexp>', 'add a new release filter to your account', :commandAddFilter],
		['list', 'retrieve a list of your filters', :commandListFilters],
		['delete <index 1> <...>', 'removes one or several filters which are identified by their numeric index', :commandDeleteFilter],
		['clear', 'remove all your release filters', :commandClearFilters],
		['database', 'get statistics on the database', :commandDatabase],
		['search <regexp>', 'search the database for release names matching the regular expression', :commandSearch],
		['download <ID or name>', 'start the download of a release', :commandDownload],
		['status', 'retrieve the status of downloads in progress', :commandStatus],
		['cancel', 'cancel a download', :commandCancel],
		['permissions', 'view your permissions/limits', :commandPermissions],
		['exit', 'terminate your session', :commandExit],
		['quit', 'terminate your session', :commandExit],
		['ssh <SSH key data>', 'set the SSH key in your authorized_keys to authenticate without a password prompt', :commandSSH],
		['regexp-help', 'a short introduction to the regular expressions used by this system', :commandRegexpHelp],
		['category <path> <filter 1> <...>', 'assign a folder to a set of filters', :commandCategory],
		['delete-category <path>', 'get rid of a symlinks folder', :commandDeleteCategory],
	]
	
	def initialize(configuration, database, user, http)
		@filterLengthMaximum = configuration::Shell::FilterLengthMaximum
		@filterCountMaximum = configuration::Shell::FilterCountMaximum
		@searchResultMaximum = configuration::Shell::SearchResultMaximum
		@sshKeyMaximum = configuration::Shell::SSHKeyMaximum
		@releaseSizeLimit = configuration::Torrent::SizeLimit
		@database = database
		@user = user
		@sccReleases = @database[:scene_access_data]
		@filters = @database[:user_release_filter]
		@http = http
		@torrentPath = configuration::Torrent::Path::Torrent
		@userPath = Nil.joinPaths(configuration::Torrent::Path::User, @user.name)
		@filteredPath = Nil.joinPaths(@userPath, configuration::Torrent::Path::Filtered)
	end
	
	def error(line)
		puts Nil.red(line)
	end
	
	def warning(line)
		puts Nil.yellow(line)
	end
	
	def success(line)
		puts Nil.lightGreen(line)
	end
	
	def run
		prefix = @user.shellPrefix
		while true
			begin
				line = Readline.readline(prefix, true)
				if line == nil
					puts Nil.cyan('Terminating.')
					exit
				end
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
					error('You have entered an invalid regular expression: ' + exception.message)
					next
				rescue Sequel::DatabaseError => exception
					error "DBMS error: #{exception.message.chop}"
					next
				end
				
				error('Invalid command.') if !validCommand
			rescue Interrupt
				puts Nil.cyan('Interrupt.')
				exit
			rescue EOFError
				puts Nil.cyan('Terminating.')
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
			puts "#{Nil.white name} - #{description}"
		end
	end
	
	def commandAddFilter
		if @argument.empty?
			warning 'Please specify a filter to add.'
			return
		end
		filter = @argument
		if filter.size > @filterLengthMaximum
			error "Your filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		if @filters.where(user_id: @user.id).count > @filterCountMaximum
			error "You have too many filters (#{filterCountMaximum})."
			return
		end
		#check if it is a valid regular expression first
		@database["select 1 where '' ~* ?", @argument].all
		@filters.insert(user_id: @user.id, filter: filter)
		success "Your filter has been added."
	end
	
	def commandListFilters
		filters = @filters.where(user_id: @user.id).order(:id).select(:filter, :category)
		if filters.empty?
			puts 'You currently have no filters.'
			return
		end
		puts Nil.white('This is a list of your filters:')
		counter = 1
		filters.each do |filter|
			info = "#{counter.to_s}. #{filter[:filter]}"
			category = filter[:category]
			if category == nil
				puts info
			else
				puts "#{info} #{Nil.lightRed "[#{category}]"}"
			end
			counter += 1
		end
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
	
	def commandDeleteFilter
		if @arguments.empty?
			warning 'Please specify the index of a filter to delete.'
			return
		end
		
		@database.transaction do
			ids = convertFilterIndices(@arguments)
			return if ids == nil
			
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
		puts "Number of releases in the database: #{Nil.yellow(@sccReleases.count.to_s)}"
		sizeString = Nil.getSizeString(@sccReleases.sum(:release_size))
		puts "Size of releases available on demand: #{Nil.yellow sizeString}"
	end
	
	def commandSearch
		if @argument.empty?
			warning "Specify a regular expression to look for."
			return
		end
		
		if @argument.size > @filterLengthMaximum
			error "Your search filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		
		results = @database['select site_id, section_name, name, release_date, release_size from scene_access_data where name ~* ? order by site_id desc limit ?', @argument, @searchResultMaximum]
		
		if results.empty?
			warning 'Your search yielded no results.'
			return
		end
		
		results.each do |result|
			sizeString = Nil.getSizeString(result[:release_size])
			timestamp = result[:release_date].utc.to_s
			puts "[#{result[:site_id]}] [#{result[:section_name]}] #{result[:name]} (#{sizeString}, #{timestamp})"
		end
		
		if results.count > 5
			success "Found #{results.count} results."
		end
	end
	
	def sceneAccessDownload(target)
		if target.isNumber
			id = target.to_i
			result = @database['select name, site_id, release_size from scene_access_data where site_id = ?', id]
		else
			result = @database['select name, site_id, release_size from scene_access_data where name ~* ?', target]
		end
		if result.empty?
			error 'Unable to find the release you have specified.'
			return
		end
		result = result.first
		
		size = result[:release_size]
		if size > @releaseSizeLimit
			sizeString = Nil.getSizeString size
			sizeLimitString = Nil.getSizeString @releaseSizeLimit
			
			error "This release has a size of #{sizeString} which exceeds the current limit of #{sizeLimitString}"
			return
		end
		
		puts "Attempting to queue release #{result[:name]}"
		
		administrator = 'please contact the administrator'
		
		begin
			detailsPath = "/details.php?id=#{result[:site_id]}"
			data = @http.get detailsPath
			raise HTTPError.new 'Unable to retrieve details on this release' if data == nil
			
			releaseData = ReleaseData.new data
			httpPath = releaseData.path
			
			torrentMatch = /\/([^\/]+\.torrent)/.match(httpPath)
			raise HTTPError.new 'Unable to extract the filename from the details' if torrentMatch == nil
			torrent = torrentMatch[1]
			
			torrentPath = File.expand_path(torrent, @torrentPath)
			
			if Nil.readFile(torrentPath) != nil
				warning 'This release had already been queued, overwriting it'
				#return
			end
			
			data = @http.get(httpPath)
			if data == nil
				error 'HTTP error: Unable to queue release - please contact the administrator'
				return
			end
			
			Nil.writeFile(torrentPath, data)
			
			success 'Success!'
		rescue HTTPError => exception
			error "HTTP error: #{exception.message} - #{administrator}"
		rescue ReleaseData::Error => exception
			error "An error occured parsing the details: #{exception.message} - #{administrator}"
		end
	end
	
	def commandDownload
		if @argument.empty?
			warning "You have not specified a release to download."
			return
		end
		
		#right now, there's only SCC
		sceneAccessDownload @argument
	end
	
	def commandStatus
		puts Nil.pink('STATUS!')
		puts '... just kidding, not implemented yet.'
	end
	
	def commandCancel
		puts 'Yet to be implemented, sorry.'
	end
	
	def commandExit
		puts Nil.lightGreen('See you.')
		#sleep 1
		exit
	end

	def commandPermissions
		if @user.isAdministrator
			userLevel = 'Administrator'
		else
			userLevel = 'Regular user'
		end
		puts "User level: #{Nil.yellow userLevel}"
		sizeLimitString = Nil.getSizeString @releaseSizeLimit
		puts "Size limit per release: #{Nil.yellow sizeLimitString}"
		puts "Search result limit: #{Nil.yellow(@searchResultMaximum.to_s)}"
	end
	
	def commandSSH
		if @argument.size >= @sshKeyMaximum
			error "Your SSH data exceeds the maximal length of #{@sshKeyMaximum}."
			return
		end
		if @arguments.size < 2 || @arguments.index("\n") != nil
			error "Your SSH data does not fit the following pattern: ssh-(rsa|dsa) data [comment]"
			return
		end
		type = @arguments[0]
		if !['ssh-rsa', 'ssh-dsa'].include?(type)
			error "Unknown SSH key type: #{type}"
			return
		end
		sshDirectory = "/home/warehouse/user/#{@user.name}/.ssh"
		begin
			FileUtils.mkdir(sshDirectory)
		rescue Errno::EEXIST
		rescue Errno::ENOENT
			error 'Unable to create the directory - please contract the administrator'
			return
		end
		FileUtils.chmod(0700, sshDirectory)
		keysFile = "#{sshDirectory}/authorized_keys"
		Nil.writeFile(keysFile, @argument + "\n")
		FileUtils.chmod(0600, keysFile)
		success 'Your SSH key has been changed.'
	end
	
	RegexpExamples =
	[
		['abc', "matches #{Nil.white 'blahAbc'} and #{Nil.white 'ABC!'}"],
		['first.*second', "equivalent to the 'wildcard' style notation #{Nil.white 'first*second'}, matches #{Nil.white 'xfirst123second'}"],
		['release\.name', 'you will need to escape actual dots in scene release names since the dot is a special regexp symbol for "match any character"'],
		['(a|b)', "matches all names containing an #{Nil.white 'a'} or a #{Nil.white 'b'}"],
		['^blah', "matches all names starting with #{Nil.white 'blah'}, like #{Nil.white 'blahx'} but not #{Nil.white 'xblah'}"],
		['blah$', "matches all names ending with #{Nil.white 'blah'}, like #{Nil.white 'xblah'} but not #{Nil.white 'blahx'}"],
	]
	
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
	
	def commandRegexpHelp
		puts "Here is a list of examples:"
		puts ''
		maximum = 0
		padEntries(RegexpExamples).each do |example|
			expression = example[0]
			description = example[1]
			puts "#{Nil.white expression} - #{description}"
		end
		puts "\nSearches are #{Nil.white 'case insensitive'} by default."
		puts "This system permits you to create case sensitive expressions using the overriding #{Nil.white '(?c)'} prefix."
	end
	
	def commandCategory
		if @arguments.size < 2
			warning 'Invalid argument count - the path and at least one filter index are required.'
			return
		end
		category = @arguments[0]
		indices = @arguments[1..-1]
		if category.index('..') != nil
			error 'You have specified an invalid folder.'
			return
		end
		
		@database.transaction do		
			ids = convertFilterIndices(indices)
			return if ids == nil
			ids.each do |id|
				@filters.where(id: id).update(category: category)
			end
		end
		
		if indices.size == 1
			success "Assigned category #{category} to one filter."
		else
			success "Assigned category #{category} to #{indices.size} filters."
		end
	end
	
	def commandDeleteCategory
		if @arguments.size != 1
			warning 'Invalid argument count - you need to specify the path to a category to remove.'
			return
		end
		
		category = @argument
		
		if category.index('..') != nil
			error 'You have specified an invalid path.'
			return
		end
		
		path = Nil.joinPaths(@filteredPath, category)
		begin
			FileUtils.rm_r(category)
		rescue Errno::ENOENT
			error 'No such category found in your folder.'
		end
		
		success "Removed category \"#{category}\""
	end
end
