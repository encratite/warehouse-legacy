require 'shell/stringColour'

class UserShell
	def isAdminCommand(data)
		flag = data[-1]
		return flag.class == TrueClass
	end
	
	def hasAccess(command)
		#puts "#{command[0]}: #{isAdminCommand(command)}, #{@user.isAdministrator}"
		output = !isAdminCommand(command) || @user.isAdministrator
		#puts "Output: #{output}"
		return output
	end
	
	def commandReadCommandLogs
		data = @logs.join(:user_data, id: :user_id)
		data = data.select(:user_command_log__command_time.as(:time), :user_data__name.as(:name), :user_command_log__command.as(:command))
		if @arguments.empty?
			#don't show the commands of the current user
			data = data.filter("user_data.id != #{@user.id}")
		else
			#filter out the users specified
			data = data.where('name in ?', @arguments)
		end
		data = data.order(:time)
		data = data.limit(@commandLogCountMaximum)
		data = data.all
		if data.empty?
			puts "No commands typed by other users so far."
			return
		end
		puts "Recent commands:"
		data.each do |row|
			time = row[:time].utc.to_s
			user = row[:name]
			command = row[:command]
			puts "#{time} #{stringColour user}: #{command}"
		end
	end
end
