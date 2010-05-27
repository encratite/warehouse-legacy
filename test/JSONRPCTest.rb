require 'socket'
require 'json'
require 'readline'

class JSONClient
	def initialize(user, serial, host, port, path)
		@user = user
		@serial = serial
		@commonName = 'perelman'
		@host = host
		@port = port
		@path = path
		@id = 1
	end
	
	def call(calls)
		request =
			"GET #{@path} HTTP/1.1\r\n" +
			"Host: #{@host}\r\nConnection: close\r\n" +
			"SSL-Subject: /CN=#{@commonName}/name=#{@user}\r\n" +
			"SSL-Serial: #{@serial}\r\n" +
			"\r\n"
			
		callData = []
		calls.each do |call|
			function = call[0].to_s
			arguments = call[1..-1]
			
			rpc =
			{
				'id' => @id,
				'method' => function,
				'params' => arguments,
			}
			callData << rpc
		end
		
		if callData.size == 1
			callData = callData[0]
		end
			
		request += JSON.unparse(callData)
		socket = TCPSocket.open(@host, @port)
		socket.print(request)
		puts 'Reading...'
		reply = socket.read
		puts "Read #{reply.size} bytes"
		socket.close
		
		@id += 1
		
		return reply
	end
end

def reader(client)
	while true
		line = Readline.readline('> ', true)
		string = "client.call(#{line})"
		reply = eval(string)
		puts 'Reply:'
		puts reply
	end
end

def cmdCall(client)
	line = ARGV.join(', ')
	string = "client.call(:#{line})"
	reply = eval(string)
	puts 'Reply:'
	puts reply
end

def performanceTest(client)
	while true
		puts client.call([['getTorrents']])
	end
end

def generalTest(client)
	reply = client.call(
		[
			['sum', 2, 3],
			['getInfoHashes']
		]
	)
	puts 'Reply:'
	puts reply
end

user = 'void'
serial = '01'
host = '127.0.0.1'
port = 59172
path = '/warehouse'

client = JSONClient.new(user, serial, host, port, path)
performanceTest(client)
