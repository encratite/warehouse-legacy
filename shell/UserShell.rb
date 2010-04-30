require 'nil/string'
require 'nil/file'

class UserShell
	Commands =
	[
		['help/?', 'prints this help', :commandHelp],
		['add <regular expression>', 'add a new release filter to your account', :commandAddFilter],
		['list', 'retrieve a list of your filters', :commandListFilters],
		['delete <index 1> <index 2> <...>', 'removes one or several filters which are identified by their numeric index', :commandDeleteFilter],
		['clear', 'remove all your release filters', :commandClearFilters],
		['database', 'get statistics on the database', :commandDatabase],
		['search <regular expression>', 'search the database for release names matching the regular expression', :commandSearch],
		['download <numeric identifier or release name>', 'start the download of a release', :commandDownload],
		['status', 'retrieve the status of downloads in progress', :commandStatus],
		['cancel', 'cancel a download', :commandCancel],
		['permissions', 'view your permissions/limits', :commandPermissions],
		['exit/quit', 'terminate your session', :commandExit],
	]
	
	def initialize(configuration, database, user, http)
		@filterLengthMaximum = configuration::Shell::FilterLengthMaximum
		@filterCountMaximum = configuration::Shell::FilterCountMaximum
		@searchResultMaximum = configuration::Shell::SearchResultMaximum
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
		end
	end
	
	def commandHelp
		puts 'List of available commands:'
		Commands.each do |name, description, symbol|
			puts "#{name} - #{description}"
		end
	end
	
	def commandAddFilter
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
		@filters.insert(user_id: @user.id, filter: filter)
		puts "Your filter has been added."
	end
	
	def commandListFilters
		filters = @filters.where(user_id: @user.id).select(:filter)
		if filters.empty?
			puts 'You currently have no filters.'
			return
		end
		puts 'This is a list of your filters:'
		counter = 1
		filters.each do |filter|
			puts "#{counter}. #{filter[:filter]}"
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
	end
	
	def commandSearch
		if @argument.empty?
			puts "Specify a regular expression to look for."
			return
		end
		
		if @argument.size > @filterLengthMaximum
			puts "Your search filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		
		results = @releases.filter(name: Regexp.new(@argument))
		results = results.select(:site_id, :section_name, :name, :release_date, :release_size)
		results = results.limit(@searchResultMaximum)
		
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
end
