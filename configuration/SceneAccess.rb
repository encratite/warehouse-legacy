require 'site/sceneaccess/SceneAccessReleaseData'
require 'site/sceneaccess/SceneAccessIRCHandler'

require 'secret/SceneAccess'

module SceneAccessConfiguration
  module HTTP
    Server = 'sceneaccess.org'
    SSL = false
    #Cookies are secret
  end

  module IRC
    Server = 'irc.sceneaccess.org'
    Port = 6667
    TLS = false
    #Nick is secret
    Channels = ['#announce']
    Bots =
      [
       {nick: 'SCC', host: 'bot.sceneaccess.org'}
      ]

    module Regexp
      Release = /-> ([^ ]+) \(Uploaded/
      URL = /(http:\/\/[^\)]+)\)/
    end
  end

  Log = 'sceneaccess.log'
  Table = :sceneaccess_data
  Name = 'SceneAccess'
  Abbreviation = 'SCC'

  ReleaseDataClass = SceneAccessReleaseData
  IRCHandlerClass = SceneAccessIRCHandler
end
