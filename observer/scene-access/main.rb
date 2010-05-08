$:.concat ['../../shared']

require 'SCCObserver'
require 'Configuration'

observer = SCCObserver.new(Configuration)
observer.run
