require 'configuration/Configuration'
require 'shared/database'

require 'category/Categoriser'

if ARGV.size != 1
	puts "ruby #{__FILE__} <release>"
	exit
end

release = File.basename(ARGV[0])
database = getDatabase
categoriser = Categoriser.new(Configuration, database)
categoriser.categorise(release)
