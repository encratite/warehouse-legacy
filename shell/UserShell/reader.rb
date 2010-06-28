require 'readline'

require 'nil/console'

require 'user-api/UserAPI'

class UserShell	
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
				
				#it's 1984 all over again
				@logs.insert(user_id: @user.id, command: line)
				
				Commands.each do |data|
					arguments, description, symbol = data
					next if !hasAccess(data)
					commandNames = arguments.split(' ')[0].split('/')
					next if !commandNames.include?(command)
					method(symbol).call
					validCommand = true
					break
				end
				
				error('Invalid command.') if !validCommand
			rescue UserAPI::Error => exception
				puts Nil.red("User API error: #{exception.message}")
			rescue Interrupt
				puts Nil.cyan('Interrupt.')
			rescue EOFError
				puts Nil.cyan('Terminating.')
				exit
			rescue Errno::ECONNREFUSED
				error 'Connection refused!'
			rescue Sequel::DatabaseError => exception
				error "Database error: #{exception.message}"
			end
		end
	end
end
