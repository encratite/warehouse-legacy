require 'xmlrpc/client'

class XMLRPCClient
	def initialize(host, port, path)
		@host = host
		@port = port
		@path = path
		@client = nil
	end
	
	def call(*arguments)
		tries = 2
		tries.times do
			if @client == nil
				@client = XMLRPC::Client.new(@host, @path, @port)
			end
			begin
				output = @client.call(*arguments)
				return output
			rescue Errno::EPIPE
				@client = nil
			end
		end
		raise XMLRPC::FaultException.new('Broken pipe')
	end
end
