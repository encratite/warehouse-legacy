$: += ['shared', 'site/scene-access']

require 'SCCObserver'
require 'Configuration'

observer = SCCObserver.new(Configuration)
observer.run
