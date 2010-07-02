require 'configuration/Configuration'
require 'shared/ConnectionContainer'
require 'watchdog/Watchdog'

watchdog = Watchdog.new(Configuration, ConnectionContainer.new)
watchdog.run
