$: += ['shared', 'site/torrentvault']

require 'TVObserver'
require 'Configuration'

observer = TVObserver.new(Configuration)
observer.run
