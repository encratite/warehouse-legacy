require 'shared/irc/IRCBot'
require 'shared/irc/IRCRegexp'

class IRCData
  attr_reader :server, :port, :tls, :nick, :channels, :bots, :regexp

  def initialize(server, port, tls, nick, channels, bots, releaseRegexp, urlRegexp)
    @server = server
    @port = port
    @tls = tls
    @nick = nick
    @channels = channels

    @bots = []
    bots.each do |bot|
      nick = bot[:nick]
      host = bot[:host]
      bot = IRCBot.new(nick, host)
      @bots << bot
    end

    @regexp = IRCRegexp.new(releaseRegexp, urlRegexp)
  end
end
