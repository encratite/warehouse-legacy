require 'open3'

class PipeHandler
	def initialize(commandLine, &block)
		Open3.popen3(commandLine) do |stdin, stdout, stderr|
			block.call(self)
		end
	end
end
