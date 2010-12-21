require 'nil/file'

class UserShell
  def getCommandStrings
    output = []
    Commands.each do |command, description, function|
      command = command.split(' ')[0]
      output << command
    end
    return output
  end

  def getShortestString(strings)
    minimum = nil
    strings.each do |string|
      size = string.size
      if minimum == nil || size > minimum
        minimum = size
      end
    end
    return minimum
  end

  def getLongestMatch(strings)
    return '' if strings.empty?
    offset = 0
    minimum = getShortestString(strings)
    first = strings[0]
    while offset < minimum
      allEqual = true
      byte = first[offset]
      strings[1..-1].each do |string|
        currentByte = string[offset]
        if currentByte != byte
          allEqual = false
          break
        end
      end
      break if !allEqual
      offset += 1
    end
    return first[0..(offset - 1)]
  end

  def completion(string)
    matches = []
    @commands.each do |command|
      next if command.size < string.size
      matches << command if command[0..(string.size - 1)] == string
    end
    return '' if matches.empty?
    #puts "matches: #{matches.inspect}"
    longestMatch = getLongestMatch(matches)
    if longestMatch == string && matches.size > 1
      puts "\nYour input matches #{matches.size} commands - which one do you mean?"
      matches.each do |match|
        puts Nil.white(match)
      end
      print "\r#{@prefix}#{longestMatch}"
    end
    return longestMatch
  end
end
