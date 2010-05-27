class Timer
	def initialize
		@start = Time.now
	end
	
	def stop
		difference = Time.now - @start
		milliseconds = (difference * 1000).to_i
		return milliseconds
	end
end
