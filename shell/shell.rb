require 'nil/string'

class Shell
	Commands =
	[
		['help', 'prints this help', :commandHelp]
		['exit', 'terminate your session', :commandExit],
		['add <regular expression>', 'add a new release filter to your account', :commandAddFilter],
		['list', 'retrieve a list of your filters', :commandListFilters],
		['delete <index 1> <index 2> <...>', 'removes one or several filters which are identified by their numeric index', :commandDeleteFilter],
		['clear', 'remove all your release filters', :commandClearFilters],
		['search <regular expression>', 'search the database for release names matching the regular expression', :commandSearch],
		['download <numeric identifier or release name>', 'start the download of a release', :commandDownload],
		['status', 'retrieve the status of downloads in progress', :commandStatus],
		['cancel', 'cancel a download', :commandCancel]
	]
	
	def initialize(configuration, database, user)
		@filterLengthMaximum = configuration::Shell::FilterLengthMaximum
		@database = database
		@user = user
		@filters = @database[:user_release_filter]
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
			puts "#{counter}. #{filter}"
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
			
		end
	end
end
