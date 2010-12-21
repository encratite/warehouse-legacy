require 'site/torrentvault/TorrentVaultReleaseData'
require 'site/torrentvault/TorrentVaultIRCHandler'

require 'secret/TorrentVault'

module TorrentVaultConfiguration
  module HTTP
    Server = 'www.torrentvault.org'
    #Cookies are secret
    SSL = true
  end

  module IRC
    Server = 'irc.torrentvault.org'
    Port = 9022
    TLS = true
    #Nick is secret
    Channels = ['#tv', '#tv-spam']
    Bots =
      [
       {nick: 'InfoVault', host: 'torrentvault.org'}
      ]

    InviteBot = 'TorrentVault'
    #InviteCode is secret

    module Regexp
      Release = /Name: (.+?) \[/
      URL = /(https?:\/\/[\S]+)/
    end
  end

  Log = 'torrentvault.log'
  Table = :torrentvault_data
  Name = 'TorrentVault'
  Abbreviation = 'TV'

  ReleaseDataClass = TorrentVaultReleaseData
  IRCHandlerClass = TorrentVaultIRCHandler
end
