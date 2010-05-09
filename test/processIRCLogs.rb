$: += ['shared', 'site/scene-access'

require 'nil/file'

require 'SCCObserver'
require 'Configuration'

Dir.chdir '../observer/scene-access'

lines = Nil.readLines('../../test/data/scc.log')
observer = SCCObserver.new(Configuration)
lines.each do |line|
	next if line.empty?
	observer.irc.irc.processLine(line)
end
