require 'configuration/Configuration'
require 'cleaner/Cleaner'
require 'shared/ConnectionContainer'

cleaner = Cleaner.new(Configuration, ConnectionContainer.new)
cleaner.run

