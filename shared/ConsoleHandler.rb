require 'nil/irc'

class ConsoleHandler
	def initialize(irc, log)
		@commands =
		{
			'help' => [:commandHelp, 'print help'],
			'quit' => [:commandQuit, 'quit the program'],
		}
		
		@irc = irc.irc
		@log = File.open(log, 'ab')
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
	
	def output(line)
		puts line
		@log.puts line
		@log.flush
	end
	
	def onLine(line)
		output "#{getTimestamp} | > #{line}"
	end
	
	def onEntry
		output 'Trying to enter the announce channel'
	end
	
	def onChannelMessage(channel, user, message)
		message = Nil::IRCClient.stripTags(message)
		output "\##{channel} <#{user.nick}> #{message}"
	end
	
	def onSendLine(line)
		output "#{getTimestamp} | < #{line}"
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
