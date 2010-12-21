require 'xmlrpc/client'

class XMLRPCClient
  def initialize(host, port, path)
    @host = host
    @port = port
    @path = path
    @client = nil
  end

  def performCall(&block)
    tries = 2
    message = nil
    tries.times do
      begin
        if @client == nil
          @client = XMLRPC::Client.new(@host, @path, @port)
        end
        return yield(block)
      rescue Errno::EPIPE
        @client = nil
        message = 'Broken pipe'
      rescue EOFError
        @client = nil
        message = 'End of file'
      rescue Timeout::Error
        @client = nil
        message = 'Timeout'
      rescue => error
        @client = nil
        message = "#{error.class}: #{error.message}"
      end
    end
    raise message
  end

  def call(*arguments)
    performCall { @client.call(*arguments) }
  end

  def multicall(*calls)
    performCall { @client.multicall(*calls) }
  end
end
