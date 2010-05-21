require 'nil/file'
require 'configuration/TorrentLeech'
require 'database'
require 'site/torrentleech/TorrentLeechFullHTMLParser'

files = Nil.readDirectory 'html/torrentleech'
counter = 0
parser = TorrentLeechFullHTMLParser.new
database = getDatabase
dataset = database[TorrentLeechConfiguration::Table]

files.each do |file|
	counter += 1
	process = Float(counter) / files.size * 100.0
	printf("#{file.name} (%.2f%%)", process)
	html = Nil.readFile(file.path)
	releases = parser.processData(html)
	puts "Processing #{releases.size} releases"
	releases.each do |release|
		dataset.where(site_id: release.siteId).erase
		insertData = release.getData
		dataset.insert(*insertData)
	end
end
