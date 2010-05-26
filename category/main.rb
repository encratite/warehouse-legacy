require 'nil/file'

#hack for the rtorrent cwd
base = File.expand_path(File.dirname(__FILE__))
target = Nil.joinPaths(base, '..')
Dir.chdir(target)

require 'configuration/Configuration'
require 'shared/sqlDatabase'
require 'category/Categoriser'

if ARGV.size != 1
	puts "ruby #{__FILE__} <release>"
	exit
end

release = File.basename(ARGV[0])
database = getSQLDatabase
categoriser = Categoriser.new(Configuration, database)
categoriser.categorise(release)
