require 'shared/ReleaseSite'
require 'shared/IRCHandler'
require 'shared/ConsoleHandler'

class IRCReleaseSite < ReleaseSite
	attr_reader :ircHandler
	
	#Used by IRCHandler
	attr_reader :ircData
	
	def initialize(siteData, torrentData)
		"""
		Dependencies:
		IRCHandler: OutputHandler, ReleaseHandler
		ConsoleHandler: IRCHandler
		"""
		super(siteData, torrentData)
		
		@ircHandlerClass = siteData::IRCHandlerClass
		
		ircData = siteData::IRC
		regexpData = ircData::Regexp
		@ircData = IRCData.new(
			ircData::Server,
			ircData::Port,
			ircData::Nick,
			ircData::Channels,
			ircData::Bots,
			regexpData::Release,
			regexpData::URL
		)
		
		@ircHandler = @ircHandlerClass.new(self)
		@consoleHandler = ConsoleHandler.new(@ircHandler)
	end
	
	def run
		@ircHandler.run
		@consoleHandler.run
	end
end
