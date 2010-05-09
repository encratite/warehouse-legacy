module SceneAccess
	module HTTP
		Server = 'sceneaccess.org'
		Cookies =
		{
			'uid' => '953675',
			'pass' => 'ab31c2bdf48e5e9d60d19b7f40cf0de0'
		}
	end
	
	module IRC
		Server = 'irc.sceneaccess.org'
		Port = 6667
		Nick = 'malleruet'
		Channels = ['#scc-announce']
		
		module Bot
			Nick = 'SCC'
			Host = 'csops.sceneaccess.org'
		end
		
		module Regexp
			Release = /-> ([^ ]+) \(Uploaded/
			URL = /(http:\/\/[^\)]+)\)/
		end
	end
	
	Log = 'scene-access.log'
	Table = :scene_access_data
	Name = 'SceneAccess'
	Abbreviation = 'SCC'
end

require 'shared/HTTPHandler'
require 'shared/IRCData'
require 'shared/IRCBot'
require 'shared/IRCRegexp'

class ReleaseSite
	attr_reader :http, :irc
	attr_reader :log, :table, :name, :abbreviation
	
	def initialize(configuration)
		http = configuration::HTTP
		@http = HTTPHandler.new(http::Server, http::Cookies)
		
		@log = configuration::Log
		@table = configuration::Table
		@name = configuration::Name
		@abbreviation = configuration::Abreviation
	end
end
