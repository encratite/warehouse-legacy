require 'openssl'
require 'fileutils'
require 'json'

require 'nil/file'
require 'nil/ipc'

require 'shared/User'

require 'notification/NotificationClient'
require 'notification/NotificationProtocol'

require 'json/JSONRPCNotificationHandler'

class NotificationServer < Nil::IPCServer
	TypeHandlers =
	{
		'rpc' => :rpcHandler
	}
	
	def initialize(configuration, connections)
		Thread.abort_on_exception = true

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
		
		@shellGroup = configuration::User::ShellGroup
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
	
	def initialisePermissions
		File.chmod(0660, @path)
		uid = Process.uid
		gid = Etc.getgrnam(@shellGroup).gid
		File.chown(uid, gid, @path)
	end
	
	def output(line)
		@output.output(line)
	end
	
	def run
		#run IPC server in separate threads
		Thread.new { super }
		@tcpServer = TCPServer.new(@port)
		#option = [3, 0].pack("L_2")
		#puts @tcpServer.getsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO).inspect
		#@tcpServer.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, option)
		#puts @tcpServer.getsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO).inspect
		@sslServer = OpenSSL::SSL::SSLServer.new(@tcpServer, @ctx)
		runServer
	end
	
	def socketHook
		initialisePermissions
	end
	
	def runServer
		while true
			begin
				socket = @sslServer.accept
				output "accept returned: #{socket.inspect}"
				Thread.new { handleClient(socket) }
			rescue OpenSSL::SSL::SSLError => exception
				#"SSL_write:: bad write retry" appears to occur rather randomly here, wreaking havoc
				output "An SSL exception occured: #{exception.message} (socket: #{socket.inspect})"
				closeSocket socket
			rescue RuntimeError => exception
				closeSocket socket
				output "Runtime error: #{exception.message}"
			end
		end
	end
	
	def closeSocket(socket)
		begin
			if socket == nil
				output 'Attempted to close a nil socket!'
			else
				output "Closing socket #{socket.inspect}"
				socket.close
			end
		rescue IOError
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
		@clientMutex.synchronize { @clients << client }
		
		processClientCommunication client
	end
	
	def processClientCommunication(client)
		name = client.user.name
		output "User #{name} connected"
		while true
			begin
				result = client.receiveData
			rescue Nil::SerialisedCommunication::CommunicationError => exception
				output "Erroneous communication with user #{name}: #{exception.message}"
				closeSocket(client.socket)
				return
			end
			if result.connectionClosed
				output "User #{name} disconnected"
				#unnecessary, I guess
				closeSocket(client.socket)
				return
			end
			
			input = result.value
			begin
				processClientInput(client, input)
			rescue RuntimeError => exception
				backtrace = exception.backtrace.join "\n"
				output "An exception of type #{exception.class} occured:\nbacktrace"
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
		begin
			user = client.user
			user.address = client.socket.peeraddr[3]
			returnValue = @rpc.processRPCRequests(client, input)
			#puts "Input: #{input.inspect}"
			#puts "Output keys: #{returnValue.keys.inspect}"
			output =
			{
				'type' => 'rpcResult',
				'data' => returnValue,
			}
			client.sendData(output)
		rescue SystemCallError => exception
			output "RPC handling error: #{exception.message}"
			return nil
		end
	end
	
	def clientError(client, message)
		error = NotificationProtocol.createUnit('error', message)
		client.sendData(error)
	end
	
	#user may be either a username or a user ID
	def notify(target, type, content)
		isId = target.class == Fixnum
		userData = @database[:user_data]
		if isId
			result = userData.where(id: target)
		else
			result = userData.where(name: target)
		end
		result = result.all
		return Nil.IPCError.new("No such user: #{username}") if result.empty?
		user = User.new(result.first)
		
		unit = NotificationProtocol.notificationUnit(type, content)
		isOnline = false
		@clientMutex.synchronize do
			@clients.each do |client|
				next if client.user.id != user.id
				client.sendData(unit)
				isOnline = true
			end
		end
		
		if isOnline
			output "Notification for user \"#{user.name}\" of type \"#{type}\": #{content}"
			#update the last notification timestamp so getNewNotifications really only returns the new ones
			newTime = Time.now.utc
			@database[:user_data].where(id: user.id).update(last_notification: newTime)
		else
			output "Storing notification for offline user #{user.name} of type \"#{type}\": #{content}"
		end
		#notifications should be stored either way really - we want a full history anyways
		data =
		{
			'user_id' => user.id,
			'notification_type' => type,
			'content' => JSON::unparse(content)
		}
		@database[:user_notification].insert(data)
		
		return isOnline
	end
end
