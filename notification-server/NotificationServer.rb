require 'openssl'
require 'fileutils'

require 'nil/file'
require 'nil/ipc'

require 'notification-server/NotificationClient'

class NotificationServer < Nil::IPCServer
	def initialize(configuration, connections)
		@port = configuration::Port
		path = configuration::Socket
		FileUtils.mkdir_p(File.dirname(path))
		super(path)
		@database = connections.sqlDatabase
		@methods += [:notify]
		@clientMutex = Mutex.new
		@clients = []
		initialiseTLS(configuration)
	end
	
	def initialiseTLS(configuration)
		certificatePath = configuration::TLS::ServerCertificate
		keyPath = configuration::TLS::ServerKey
		caPath = configuration::TLS::CertificateAuthority
		
		puts "Using certificate #{certificatePath}"
		puts "Using key #{keyPath}"
		puts "Using certificate authority #{caPath}"
		
		@ctx = OpenSSL::SSL::SSLContext.new()
		@ctx.cert = OpenSSL::X509::Certificate.new(File::read(certificatePath))
		@ctx.key = OpenSSL::PKey::RSA.new(File::read(keyPath))
		@ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
		@ctx.ca_file = caPath
	end
	
	def run
		#run IPC server in separate threads
		Thread.new { super }
		@tcpServer = TCPServer.new(@port)
		@sslServer = OpenSSL::SSL::SSLServer.new(@tcpServer, @ctx)
		runServer
	end
	
	def runServer
		while true
			begin
				client = @sslServer.accept
				Thread.new { handleClient(client) }
			rescue OpenSSL::SSL::SSLError => exception
				puts "An SSL exception occured: #{exception.message}"
			end
		end
	end
	
	def handleClient(client)
		clientObject = NotificationClient.new(client, @database)
		@clientMutex.synchronize { @clients << clientObject }
	end
	
	def notify(user, type, message)
	end
end
