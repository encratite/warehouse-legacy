$:.concat ['../shared', '../manager']

require 'nil/file'

require 'SCCManager'
require 'Configuration'

lines = Nil.readLines('data/scc.log')
manager = SCCManager.new(Configuration)
lines.each do |line|
	next if line.empty?
	manager.irc.irc.processLine(line)
end
