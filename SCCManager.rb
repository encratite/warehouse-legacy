require 'HTTPHandler'
require 'IRCHandler'
require 'ConsoleHandler'

class SCCManager
	attr_reader :http, :irc
	
	def initialize(configuration)
		cookieData = configuration.const_get(:Cookie)
		uId = cookieData.const_get(:UId)
		pass = cookieData.const_get(:Pass)
		
		@http = HTTPHandler.new(uId, pass)
		
		ircData = configuration.const_get(:IRC)
		server = ircData.const_get(:Server)
		nick = ircData.const_get(:Nick)
		
		@irc = IRCHandler.new(server, nick)
		
		@console = ConsoleHandler.new(self)
	end
	
	def run
		@irc.run
		@console.run
	end
end
