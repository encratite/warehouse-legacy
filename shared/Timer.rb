class Timer
  def initialize
    reset
  end

  def reset
    @start = Time.now
  end

  def stop
    difference = Time.now - @start
    milliseconds = (difference * 1000).to_i
    reset
    return milliseconds
  end
end
