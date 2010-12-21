class WatchedProcess
  attr_reader :name
  attr_accessor :oldIsActive, :isActive

  def initialize(name, pattern)
    @name = name
    @pattern = pattern
    @oldIsActive = nil
    @isActive = nil
  end

  def ==(input)
    return @pattern.match(input.cmdline) != nil
  end
end
