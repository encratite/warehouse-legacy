require 'nil/file'
require 'digest/sha2'
require 'fileutils'

path = 'html/torrentvault'
files = Nil.readDirectory(path)
files.each do |file|
  data = Nil.readFile(file.path)
  hash = Digest::SHA256.hexdigest(data)
  newPath = Nil.joinPaths(path, hash)
  if File.exists?(newPath)
    puts "Collision: #{newPath}"
    exit
  end
  puts "Renaming #{file.path} to #{newPath}"
  FileUtils.mv(file.path, newPath)
end
