require_relative 'configuration/Configuration'
require_relative 'cleaner/Cleaner'
require_relative 'shared/ConnectionContainer'

cleaner = Cleaner.new(Configuration, ConnectionContainer.new)
begin
	cleaner.run
rescue Interrupt
	exit
end

