$: << '.'

require 'site/torrentleech/TorrentLeechReleaseData'

input = "Wednesday 11th September 2001 02:36:48 PM"
test = TorrentLeechReleaseData.parseDateString(input)

puts test.inspect
