require 'nil/file'

class ConfigurationEntry
  attr_accessor :target, :priority

  def initialize(target, priority = 0)
    @target = target
    @priority = priority
  end

  def <=>(input)
    return -(@priority <=> input.priority)
  end
end

#this is intended to provide local configuration overrides for testing/debugging purposes without messing with the repository contents
def loadConfigurationFiles
  baseDirectory = 'configuration'

  mainDirectory = 'Configuration'
  customDirectory = 'myConfiguration'

  mainPath = Nil.joinPaths(baseDirectory, mainDirectory)
  customPath = Nil.joinPaths(baseDirectory, customDirectory)

  targets = Nil.readDirectory(mainPath)
  targets = targets.map{|x| ConfigurationEntry.new(x)}

  priorityFiles =
    [
     #need to make an exception for the User.rb here because it needs to get included first
     ['User', 2],
     ['Torrent', 1],
    ]

  priorityFiles.each do |name, priority|
    name = "#{name}.rb"
    targets.each do |entry|
      if entry.target.name == name
        entry.priority = priority
        break
      end
    end
  end

  targets.sort!

  targets.each do |entry|
    target = entry.target
    customPath = Nil.joinPaths(customPath, target.name)
    if File.exists?(customPath)
      require customPath
    else
      require target.path
    end
  end
end

loadConfigurationFiles
