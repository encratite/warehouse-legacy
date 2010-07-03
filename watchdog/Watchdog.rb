require 'sys/proctable'
require 'watchdog/WatchedProcess'

class Watchdog
	def initialize(configuration, connections)
		@notification = connections.notificationClient
		watchdogData = configuration::Watchdog
		@programs = watchdogData::Programs.map do |name, pattern|
			WatchedProcess.new(name, Regexp.new(pattern))
		end
		@delay = watchdogData::Delay
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
						#the process was relaunched
					else
						#the process terminated
					end
				end
				program.oldIsActive = program.isActive
			end
			sleep @delay
		end
	end
end
