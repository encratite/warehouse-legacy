require 'readline'

require 'nil/console'

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
				
				begin
					Commands.each do |data|
						arguments, description, symbol = data
						isAdminCommand = data[-1].class == TrueClass
						if isAdminCommand && !@user.isAdmin
							break
						end
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
end
