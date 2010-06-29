require 'open3'
require 'thread'

class PipeHandler
	ReadLimit = 4096
	
	def initialize(commandLine, &block)
		@queue = Queue.new
		Open3.popen3(commandLine) do |stdin, stdout, stderr|
			[stdout, stderr].each do |io|
				Thread.new { ioHandler io }
			end
			@stdin = stdin
			block.call(self)
		end
	end
	
	def getMessage
		return @queue.pop
	end
	
	def <<(input)
		@stdin.puts(input)
	end
	
	def ioHandler(io)
		while true
			#puts "Reading..."
			data = io.readpartial(ReadLimit)
			#puts "Read: #{data}"
			if data.empty?
				#EOF signal?
				@queue << nil
			end
			@queue << data
		end
	end
end
