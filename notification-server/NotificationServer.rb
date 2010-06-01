require 'openssl'

require 'shared/ipc'

require 'nil/file'

class NotificationServer < Nil::IPCServer
	def initialize(configuration, connections)
		@address = configuration::Address
		@port = configuration::Port
		super(path)
		@database = connections.sqlDatabase
		@methods += [:notify]
		@clientMutex = Mutex.new
		@clients = []
		initialiseTLS(configuration)
	end
	
	def loadData(path, &block)
		data = Nil.readFile(path)
		raise "Unable to load TLS data from #{path}" if data == nil
		return yield(data)
	end
	
	def initialiseTLS(configuration)
		x509 = lambda { |data| OpenSSL::X509::Certificate.new(data) }
		
		tlsData =
		[
			[:CertificateAuthority, x509],
			[:ServerCertificate, x509],
			[:PrivateKey, lambda { |data| OpenSSL::PKey::RSA.new(data) }]
		]
		
		tlsData.each do |symbol, function|
			path = configuration.const_get(symbol)
			symbolString = symbol.to_s
			localSymbol = ('@' + symbolString[0].downcase + symbolString[1..-1]).to_sym
			tlsObject = loadData(path) { |data| function.call(data) }
			instance_variable_set(localSymbol, tlsObject)
		end
		
		@ctx = OpenSSL::SSL::SSLContext.new()
		@ctx.key = @privateKey
		@ctx.cert = @serverCertificate
		@ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
		@ctx.ca_path = @certificateAuthority
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
			client = @sslServer.accept
			@clientMutex.synchronize { @clients << client }
			Thread.new { handleClient(client) }
		end
	end
	
	def handleClient(client)
	end
	
	def notify(user, type, message)
	end
end
