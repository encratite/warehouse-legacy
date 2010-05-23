require 'socket'
require 'json'

host = '127.0.0.1'
port = 59172

socket = TCPSocket.open(host, port)
request = "GET / HTTP/1.1\r\nHost: #{host}\r\nConnection: close\r\n\r\n"

rpc =
{
	'id' => 1,
	'method' => 'sum',
	'params' => [123, 456],
}

request += JSON.unparse(rpc)

socket.print(request)
reply = socket.read

puts 'Reply:'
puts reply
