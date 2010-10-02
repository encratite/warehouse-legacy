require 'sys/proctable'
require 'watchdog/WatchedProcess'
require 'shared/OutputHandler'
require 'nil/file'

class Watchdog
	def initialize(configuration, connections)
		logPaths = Nil.joinPaths(configuration::Logging::Path, configuration::Watchdog::Log)
		@output = OutputHandler.new(logPaths)
		@database = connections.sqlDatabase
		@notification = connections.notificationClient
		watchdogData = configuration::Watchdog
		@programs = watchdogData::Programs.map do |name, pattern|
			WatchedProcess.new(name, Regexp.new(pattern))
		end
		@delay = watchdogData::Delay
		@adminIDs = getAdminIDs
		puts "Number of administrators: #{@adminIDs.size}"
	end
	
	def getAdminIDs
		users = @database[:user_data]
		ids = users.where(is_administrator: true).select(:id)
		ids = ids.map {|x| x[:id]}
		return ids
	end
	
	def output(line)
		@output.output(line)
	end
	
	def notifyAdmins(message)
		output message
		severity = 'error'
		@adminIDs.each do |id|
			@notification.serviceMessage(id, severity, message)
		end
	end
	
	def run
		while true
			@programs.each do |program|
				program.isActive = false
			end
			Sys::ProcTable.ps do |process|
				offset = @programs.index(process)
				next if offset == nil
				program = @programs[offset]
				program.isActive = true
			end
			@programs.each do |program|
				if program.oldIsActive != program.isActive
					#a change occured
					if program.isActive
						#the process was relaunched - this does not require any notification really because the administrator is responsible for this
						output "Service \"#{program.name}\" has been restored"
					else
						#the process terminated - this should never happen
						#notify the adminstrator about this problem
						message = "Service \"#{program.name}\" terminated unexpectedly"
						notifyAdmins message
					end
				end
				program.oldIsActive = program.isActive
			end
			sleep @delay
		end
	end
end
