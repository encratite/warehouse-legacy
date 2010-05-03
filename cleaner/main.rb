$:.concat ['../shared']

require 'Configuration'
require 'Cleaner'

cleaner = Cleaner.new Configuration
cleaner.run

