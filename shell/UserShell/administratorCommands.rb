class UserShell
	def isAdminCommand(data)
		return data[-1].class == TrueClass
	end
	
	def hasAccess(command)
		return !isAdminCommand(command) || @user.isAdmin
	end
	
	def commandReadCommandLogs
		data = @logs.join(:user_data, id: :user_id)
		data = data.filter{|x| x.id != @user.id}
		data = data.select(:user_command_log__command_time.as(:time), :user_data__name.as(:name), :user_command_log__command.as(:command))
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
			puts "#{time} #{user}: #{command}"
		end
	end
end
