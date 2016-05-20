require 'nil/irc'

class OutputHandler
  def initialize(log)
    @logPath = log
    @log = nil
  end

  def getTimestamp
    output = Time.now.utc.to_s
    output = output.split(' ')[0..-2].join(' ')
    return output
  end

  def output(line)
    line = "#{getTimestamp} #{line}"
    puts line
    begin
      @log = File.open(@logPath, 'ab') if @log == nil
      @log.puts line
      @log.flush
    rescue
      puts 'Failed to write to log file'
    end
  end

  def onLine(line)
    output "| > #{line}"
  end

  def onChannelMessage(channel, user, message)
    message = Nil::IRCClient.stripTags(message)
    output "#{channel} <#{user.nick}> #{message}"
  end

  def onSendLine(line)
    output "| < #{line}"
  end
end
