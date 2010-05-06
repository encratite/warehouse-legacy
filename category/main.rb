base = File.expand_path(__FILE__) + '/..'
$:.concat [base, "#{base}/shared"]

require 'Configuration'
require 'database'

require 'Categoriser'

if ARGV.size != 1
	puts "ruby #{__FILE__} <release>"
	exit
end

release = Dir.basename(ARGV[0])
database = getDatabase(Configuration)
categoriser = Categoriser.new(configuration, database)
categoriser.categorise(release)
