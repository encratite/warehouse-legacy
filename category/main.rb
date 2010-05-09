base = File.expand_path(File.dirname(__FILE__))
Dir.chdir base
$: << 'shared'

require 'Configuration'
require 'database'

require 'Categoriser'

if ARGV.size != 1
	puts "ruby #{__FILE__} <release>"
	exit
end

release = File.basename(ARGV[0])
database = getDatabase
categoriser = Categoriser.new(Configuration, database)
categoriser.categorise(release)
