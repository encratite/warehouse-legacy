class ConsoleHandler
	def initialize(irc)
		@commands =
		{
			'help' => [:commandHelp, 'print help'],
			'quit' => [:commandQuit, 'quit the program'],
			'exit' => [:commandQuit, 'exit the program'],
		}
		
		@irc = irc
	end
	
	def commandHelp(arguments)
		puts 'Available commands:'
		@commands.each do |command, data|
			symbol, description = data
			puts "#{command} - #{description}"
		end
	end
	
	def commandQuit(arguments)
		puts 'Disconnecting from IRC server'
		@irc.quit('Shutdown')
		puts 'Quitting'
		exit
	end
	
	def terminate
		puts 'Terminating'
		exit
	end
	
	def run
		begin
			while true
				print '> '
				line = STDIN.readline
				tokens = line.split(' ')
				next if tokens.empty?
				command = tokens[0]
				arguments = tokens[1..-1]
				commandData = @commands[command]
				if commandData == nil
					puts "Unknown command: #{command}"
					next
				end
				symbol, description = commandData
				function = method(symbol)
				function.call(arguments)
			end
		rescue EOFError
			terminate
		rescue Interrupt
			terminate
		end
	end
end
