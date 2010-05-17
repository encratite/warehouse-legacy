require 'nil/string'
require 'nil/file'
require 'nil/console'
require 'nil/network'

require 'fileutils'
require 'readline'

require 'configuration/Configuration'

require 'shell/Timer'
require 'shell/SearchResult'

require 'shared/sites'

require 'shell/UserShell/commandDescriptions'

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
	
	def getCommandStrings
		output = []
		Commands.each do |command, description, function|
			command = command.split(' ')[0]
			output << command
		end
		return output
	end
	
	def getShortestString(strings)
		minimum = nil
		strings.each do |string|
			size = string.size
			if minimum == nil || size > minimum
				minimum = size
			end
		end
		return minimum
	end
	
	def getLongestMatch(strings)
		return '' if strings.empty?
		offset = 0
		minimum = getShortestString(strings)
		first = strings[0]
		while offset < minimum
			allEqual = true
			byte = first[offset]
			strings[1..-1].each do |string|
				currentByte = string[offset]
				if currentByte != byte
					allEqual = false
					break
				end
			end
			break if !allEqual
			offset += 1
		end
		return first[0..(offset - 1)]
	end
	
	def completion(string)
		matches = []
		@commands.each do |command|
			next if command.size < string.size
			matches << command if command[0..(string.size - 1)] == string
		end
		return '' if matches.empty?
		#puts "matches: #{matches.inspect}"
		longestMatch = getLongestMatch(matches)
		if longestMatch == string && matches.size > 1
			puts "\nYour input matches #{matches.size} commands - which one do you mean?"
			matches.each do |match|
				puts Nil.white(match)
			end
			print "\r#{@prefix}#{longestMatch}"
		end
		return longestMatch
	end
	
	def debug(line)
		if @user.isAdministrator
			puts "#{Nil.white 'DEBUG'}: #{line}"
		end
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
		@prefix = @user.shellPrefix
		Readline.completion_proc = method(:completion)
		Readline.completion_append_character = nil
		while true
			begin
				line = Readline.readline(@prefix, true)
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
	
	def printData(data)
		data = data.map { |description, value| [description + ':', value] }
		padEntries(data).each do |description, value|
			puts "#{description} #{Nil.yellow value}"
		end
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
end
