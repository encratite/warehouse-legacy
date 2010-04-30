require 'nil/irc'

class ConsoleHandler
	def initialize(manager)
		@manager = manager
		
		@commands =
		{
			'help' => [:commandHelp, 'print help'],
			'quit' => [:commandQuit, 'quit the program'],
		}
		
		@irc = @manager.irc.irc
	end
	
	def getTimestamp
		output = Time.now.utc.to_s
		output = output.split(' ')[0..-2].join(' ')
		return output
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
	
	def onLine(line)
		puts "#{getTimestamp} | > #{line}"
	end
	
	def onEntry
		puts 'Trying to enter the announce channel'
	end
	
	def onChannelMessage(channel, user, message)
		message = Nil::IRCClient.stripTags(message)
		puts "\##{channel} <#{user.nick}> #{message}"
	end
	
	def onSendLine(line)
		puts "#{getTimestamp} | < #{line}"
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
