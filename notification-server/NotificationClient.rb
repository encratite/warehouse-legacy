require 'openssl'
require 'shared/ssl'

class NotificationClient
	attr_reader :socket
	
	def initialize(socket, database)
		@socket = socket
		name = extractCertificateName(OpenSSL::X509::Certificate.new(@socket.peer_cert).subject)
		puts name
	end
end
