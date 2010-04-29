require 'nil/string'
require 'nil/file'

class Shell
	Commands =
	[
		['help', 'prints this help', :commandHelp],
		['exit', 'terminate your session', :commandExit],
		['add <regular expression>', 'add a new release filter to your account', :commandAddFilter],
		['list', 'retrieve a list of your filters', :commandListFilters],
		['delete <index 1> <index 2> <...>', 'removes one or several filters which are identified by their numeric index', :commandDeleteFilter],
		['clear', 'remove all your release filters', :commandClearFilters],
		['database', 'get statistics on the database', :commandDatabase],
		['search <regular expression>', 'search the database for release names matching the regular expression', :commandSearch],
		['download <numeric identifier or release name>', 'start the download of a release', :commandDownload],
		['status', 'retrieve the status of downloads in progress', :commandStatus],
		['cancel', 'cancel a download', :commandCancel]
	]
	
	def initialize(configuration, database, user, http)
		@filterLengthMaximum = configuration::Shell::FilterLengthMaximum
		@filterCountMaximum = configuration::Shell::FilterCountMaximum
		@searchResultMaximum = configuration::Shell::SearchResultMaximum
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
			
			Commands.each do |name, description, symbol|
				next if name != command
				method(symbol).call
				next
			end
			
			puts 'Invalid command.'
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
		filters = @filters.where(user_id: @user.id).filter(:filter)
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
		
		indices = @arguments.map { |index| index.to_i }
		indices.each do |index|
			@filters.limit(1, index).delete
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
		
		if filter.size > @filterLengthMaximum
			puts "Your search filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		
		results = @releases.filter(name: Regexp.new(@argument)).limit(@searchResultMaximum)
		results.filter(:site_id, :section_name, :name, :release_date, :release_size, :seeder_count)
		
		if results.empty?
			puts 'Your search yielded no results.'
			return
		end
		
		sizeString = Nil.getSizeString(result[:release_size])
		
		results.each do |result|
			puts "[#{result[:site_id]}] [#{result[:section_name]}] #{result[:name]} (#{sizeString}, #{result[:release_date]}, #{result[:seeder_count]} seed(s))"
		end
		
		if results.size > 5
			puts "Found #{results.size} results."
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
		result = result.filter(:name, :torrent_path)
		if result.empty?
			puts 'Unable to find the release you have specified.'
			return
		end
		result = result.first
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
			puts 'This release has already been queued'
			return
		end
		
		data = @http.get(httpPath)
		if data == nil
			puts 'HTTP error: Unable to queue release'
			return
		end
		
		Nil.writeFile(torrentPath, torrentData)
		
		puts 'Success!'
	end
	
	def commandStatus
		puts 'STATUS... just kidding, not implemented yet.'
	end
	
	def commandCancel
		puts 'Yet to be implemented, sorry.'
	end
end
