require 'socket'
require 'openssl'

require 'notification/NotificationClient'

require 'configuration/Configuration'

class TestClient < NotificationClient
	def rpc(*arguments)
		puts "Executing #{arguments.inspect}:"
		jsonData = getJSONRPCData(*arguments)
		sendData(jsonData)
		return readAndPrint
	end
	
	def readAndPrint
		data = receiveData
		if data.connectionClosed
			puts 'Disconnected'
			exit
		end
		value = data.value
		puts value.inspect
		return value
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
	
	client = TestClient.new(sslSocket, nil)
	client.rpc('getNotificationCount')
	client.rpc('getNewNotifications')
	notifications = client.rpc('getOldNotifications', 0, 5)
	puts "Notification count: #{notifications.size}"
	notifications = client.rpc('getOldNotifications', -1, 100)
	client.rpc('generateNotification', 'test', 'test')	
rescue OpenSSL::SSL::SSLError => exception
	puts "An SSL exception occured: #{exception.message}"
end
