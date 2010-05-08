$:.concat ['../shared', '../observer']

require 'nil/file'

require 'SCCObserver'
require 'Configuration'

lines = Nil.readLines('data/scc.log')
observer = SCCObserver.new(Configuration)
lines.each do |line|
	next if line.empty?
	observer.irc.irc.processLine(line)
end
