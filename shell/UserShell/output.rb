require 'nil/console'

class UserShell
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
	
	def printData(data)
		data = data.map { |description, value| [description + ':', value] }
		padEntries(data).each do |description, value|
			puts "#{description} #{Nil.yellow value}"
		end
	end
end
