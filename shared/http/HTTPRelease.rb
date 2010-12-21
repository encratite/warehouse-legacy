class HTTPRelease
  class Error
    attr_reader :message

    def initialize(message)
      @message = message
    end
  end

  attr_reader :name, :siteId

  def getEntry(container, offset, default)
    return default if offset >= container.size
    return container[offset].inspect
  end

  def initialize(data, symbols)
    if data.size != symbols.size
      puts 'Mismatch breakdown:'
      offset = 0
      limit = [symbols.size, data.size].max
      while offset < limit
        symbol = getEntry(symbols, offset, 'Undefined symbol')
        match = getEntry(data, offset, 'Undefined match')
        puts "#{symbol}: #{match}"
        offset += 1
      end
      raise "Match size/symbol count mismatch in a #{self.class}: #{data.inspect}"
    end

    offset = 0
    while offset < symbols.size
      symbol = ('@' + symbols[offset].to_s).to_sym
      value = data[offset]
      instance_variable_set(symbol, value)
      offset += 1
    end
  end
end
