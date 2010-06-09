require 'openssl'
require 'fileutils'

require 'nil/file'
require 'nil/ipc'

require 'shared/user'

require 'notification/NotificationClient'
require 'notification/NotificationProtocol'

require 'json/JSONRPCNotificationHandler'

class NotificationServer < Nil::IPCServer
	TypeHandlers =
	[
		'rpc' => :rpcHandler
	]
	
	def initialize(configuration, connections)
		path = configuration::Notification::Socket
		FileUtils.mkdir_p(File.dirname(path))
		
		super(path)
		
		@port = configuration::Notification::Port
		@connections = connections
		@database = connections.sqlDatabase
		@clientMutex = Mutex.new
		@clients = []
		
		log = Nil.joinPaths(configuration::Logging::Path, configuration::Notification::Log)
		@output = OutputHandler.new(log)
		
		initialiseIPC
		initialiseRPC(configuration)
		initialiseTLS(configuration::Notification)
	end
	
	def initialiseIPC
		@methods += [:notify]
	end
	
	def initialiseRPC(configuration)
		@rpc = JSONRPCNotificationHandler.new(configuration, @connections, @output)
	end
	
	def initialiseTLS(configuration)
		certificatePath = configuration::TLS::ServerCertificate
		keyPath = configuration::TLS::ServerKey
		caPath = configuration::TLS::CertificateAuthority
		
		puts 'TLS initialisation:'
		puts "Using certificate #{certificatePath}"
		puts "Using key #{keyPath}"
		puts "Using certificate authority #{caPath}"
		
		@ctx = OpenSSL::SSL::SSLContext.new()
		@ctx.cert = OpenSSL::X509::Certificate.new(File::read(certificatePath))
		@ctx.key = OpenSSL::PKey::RSA.new(File::read(keyPath))
		@ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
		@ctx.ca_file = caPath
	end
	
	def output(line)
		@output.output(line)
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
				output "An SSL exception occured: #{exception.message}"
			rescue RuntimeError => exception
				output "Runtime error: #{exception.message}"
			end
		end
	end
	
	def handleClient(socket)
		name = extractCertificateName(OpenSSL::X509::Certificate.new(socket.peer_cert).subject)
		dataset = @database[:user_data].where(name: name).all
		if dataset.empty?
			raise "Encountered an unknown user: #{name}"
		end
		user = User.new(dataset.first)
		client = NotificationClient.new(socket, user)
		@clientMutex.synchronize { @clients << clientObject }
		
		processClientCommunication client
	end
	
	def processClientCommunication(client)
		name = client.user.name
		output "User #{name} connected"
		while true
			result = client.receiveData
			if result.connectionClosed
				output "User #{name} disconnected"
				return
			end
			
			input = client.value
			begin
				processClientInput(client, input)
			rescue RuntimeError => exception
				clientError(client, exception.message)
			end
		end
	end
	
	def processClientInput(client, input)
		raise "Expected an associative array, got #{input.class} instead" if input.class != Hash
		
		type = input['type']
		data = input['data']
		
		raise 'Your request does not contain a type' if type == nil
		raise "Your type should be a string, got #{type.class} instead" if type.class != String
		raise 'Your request does not contain any data associated with the type' if data == nil
		
		handler = TypeHandlers[type]
		raise "Unknown type \"#{type}\"" if handler == nil
		
		function = method(handler)
		function.call(client, data)
	end
	
	def rpcHandler(client, input)
		if input.class == Array
			requests = input
		else
			requests = [input]
		end
		@rpc.processRPCRequests(client, requests)
	end
	
	def clientError(client, message)
		error = NotificationProtocol.createUnit('error', message)
		client.sendData(error)
	end
	
	#user may be either a username or a user ID
	def notify(user, type, content)
		isId = user.class == Fixnum
		unit = NotificationProtocol.notificationUnit(type, content)
		isOnline = false
		@clientMutex.synchronize do
			@clients.each do |client|
				next if client.user != user
				client.sendData(unit)
				isOnline = true
			end
		end
		
		if !isOnline
			if isId
				id = user
			else
				result = @database[:user_data].where(name: username).all
				return Nil.IPCError.new("No such user: #{username}") if result.empty?
				id = result.first[:id]
			end
			data =
			{
				'user_id' => id,
				'notification_type' => type,
				'content' => content
			}
			@database[:user_notification].insert(data)
		end
		
		return isOnline
	end
end
