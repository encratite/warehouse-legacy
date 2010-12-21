require 'nil/string'
require 'nil/console'

require 'shared/Timer'

class UserShell
  def getSpeedString(input)
    divisor = 1024
    output = sprintf('%.2f KiB/s', Float(input) / divisor)
    output =
      input == 0 ?
    Nil.red(output) :
      Nil.lightGreen(output)
    return output
  end

  def visualiseTorrents(input)
    input.each do |torrent|
      name = torrent.name
      downloadSpeed = getSpeedString(torrent.downloadSpeed)
      uploadSpeed = getSpeedString(torrent.uploadSpeed)
      size = Nil.getSizeString(torrent.size)
      progress = sprintf('%5.1f%%', Float(torrent.bytesDone) / torrent.size * 100.0)
      puts "[#{Nil.white progress}] #{name} (#{Nil.white size}, DL: #{downloadSpeed}, UL: #{uploadSpeed})"
    end
  end

  def getTorrents
    puts 'Retrieving torrent data...'
    timer = Timer.new
    torrents = @api.getTorrents
    delay = timer.stop
    puts "Retrieved #{Nil.white(torrents.size.to_s)} torrent(s) in #{delay} ms"
    return torrents
  end

  def commandListIncompleteTorrents
    torrents = getTorrents
    torrents.reject!{|x| x.bytesDone == x.size}
    visualiseTorrents(torrents)
  end

  def commandListAllTorrents
    torrents = getTorrents
    visualiseTorrents(torrents)
  end
end
