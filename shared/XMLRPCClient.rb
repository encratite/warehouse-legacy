require 'xmlrpc/client'

class XMLRPCClient
	def initialize(host, port, path)
		@host = host
		@port = port
		@path = path
		@client = nil
	end
	
	def performCall(&block)
		tries = 2
		message = nil
		tries.times do
			if @client == nil
				@client = XMLRPC::Client.new(@host, @path, @port)
			end
			begin
				return yield(block)
			rescue Errno::EPIPE
				@client = nil
				message = 'Broken pipe'
			rescue EOFError
				@client = nil
				message = 'End of file'
			end
		end
		raise 'Broken pipe'
	end
	
	def call(*arguments)
		performCall { @client.call(*arguments) }
	end
	
	def multicall(*calls)
		performCall { @client.multicall(*calls) }
	end
end
