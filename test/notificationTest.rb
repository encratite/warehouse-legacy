require 'socket'
require 'openssl'

require 'configuration/Configuration'

certificatePath = '/home/void/keys/client.crt'
keyPath = '/home/void/keys/client.key'
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

	"""
	while true
		STDIN.readline
	end
	"""
rescue OpenSSL::SSL::SSLError => exception
	puts "An SSL exception occured: #{exception.message}"
end
