require 'nil/file'

target = '/home/warehouse/user/'
directory = 'filtered'
group = 'warehouse-shell'

entries = Nil.readDirectory target
entries.each do |entry|
  user = entry.name
  puts "Processing #{user}"
  filtered = Nil.joinPaths(entry.path, directory)
  `mkdir #{filtered}`
  `chmod 775 #{filtered}`
  `chown #{user}:#{group} #{filtered}`
end
