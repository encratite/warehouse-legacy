def getByte
  data = []

  ranges =
    [
     'A'..'Z',
     'a'..'z',
     '0'..'9'
    ]

  ranges.each do |range|
    data += range.to_a
  end

  return data[rand(data.size)]
end

def getPassword(length)
  output = ''
  length.times { output += getByte }
  return output
end

def runProgram
  if ARGV.empty?
    puts 'Usage:'
    puts "ruby #{File.basename(__FILE__)} <length>"
    return
  end

  length = ARGV[0].to_i
  puts getPassword(length)
end

runProgram
