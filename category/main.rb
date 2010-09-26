$: << '.'

require 'nil/file'

#hack for the rtorrent cwd
base = File.expand_path(File.dirname(__FILE__))
target = Nil.joinPaths(base, '..')
Dir.chdir(target)

require 'configuration/Configuration'
require 'category/Categoriser'
require 'shared/ConnectionContainer'

if ARGV.size < 1
	puts "ruby #{__FILE__} <release>"
	exit
end

release = File.basename(ARGV.join(' '))
categoriser = Categoriser.new(Configuration, ConnectionContainer.new)
categoriser.categorise(release)
