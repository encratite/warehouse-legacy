require_relative 'configuration/Configuration'
require_relative 'shared/ConnectionContainer'
require_relative 'watchdog/Watchdog'

watchdog = Watchdog.new(Configuration, ConnectionContainer.new)
watchdog.run
