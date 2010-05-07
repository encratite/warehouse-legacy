$:.concat ['../../shared']

require 'SCCManager'
require 'Configuration'

manager = SCCManager.new(Configuration)
manager.run
