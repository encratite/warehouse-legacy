require 'socket'
require 'openssl'

require 'notification/NotificationClient'

require 'configuration/Configuration'

def readData(client)
	while true
		data = client.receiveData
		if data.connectionClosed
			puts 'Disconnected'
			return
		end
		puts data.inspect
	end
end

def getJSONRPCData(*parameters)
	function = parameters[0]
	arguments = parameters[1..-1]
	
	jsonRPCData =
	{
		'id' => 1,
		'method' => function,
		'params' => arguments
	}
	
	unitData = {
		'type' => 'rpc',
		'data' => jsonRPCData
	}
	
	return unitData
end

certificatePath = '/home/void/keys/void.crt'
keyPath = '/home/void/keys/void.key'
caPath = Configuration::Notification::TLS::CertificateAuthority

puts "Using certificate #{certificatePath}"
puts "Using key #{keyPath}"
puts "Using certificate authority #{caPath}"

ctx = OpenSSL::SSL::SSLContext.new()
ctx.cert = OpenSSL::X509::Certificate.new(File::read(certificatePath))
ctx.key = OpenSSL::PKey::RSA.new(File::read(keyPath))
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
ctx.ca_file = caPath

begin
	socket = TCPSocket.new('127.0.0.1', Configuration::Notification::Port)
	sslSocket = OpenSSL::SSL::SSLSocket.new(socket, ctx)
	puts 'Connecting...'
	sslSocket.connect

	puts 'Connected!'
	
	STDIN.readline
	
	puts 'Sending data...'
	
	client = NotificationClient.new(sslSocket, nil)
	jsonData = getJSONRPCData('getNewNotifications')
	client.sendData(jsonData)
	
	STDIN.readline
	
	puts 'Reading data...'
	
	readData(client)
rescue OpenSSL::SSL::SSLError => exception
	puts "An SSL exception occured: #{exception.message}"
end
