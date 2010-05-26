require 'xmlrpc/client'

class XMLRPCClient
	def initialize(host, port, path)
		@host = host
		@port = port
		@path = path
	end
	
	def call(*arguments)
		client = XMLRPC::Client.new(@host, @path, @port)
		output = client.call(*arguments)
		return output
	end
end
