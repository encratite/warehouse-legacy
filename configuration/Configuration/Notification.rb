module Configuration
	module Notification
		#address unused by TCPServer?
		Address = '0.0.0.0'
		Port = 43841
		Socket =
			Nil.getHostname == 'perelman' ?
			User.getPath('socket') :
			User.getPath('code/warehouse/notification/socket/socket')
		Log = 'notification.log'
		
		module TLS
			CertificateAuthority = '/etc/warehouse/keys/certificate-authority.crt'
			ServerCertificate = '/etc/warehouse/keys/server.crt'
			ServerKey = '/etc/warehouse/keys/server.key'
		end
	end
end
