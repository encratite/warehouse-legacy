require 'nil/file'
require 'configuration/TorrentLeech'
require 'shared/database'
require 'site/torrentleech/TorrentLeechFullHTMLParser'
require 'pg'

files = Nil.readDirectory 'html/torrentleech'
counter = 0
parser = TorrentLeechFullHTMLParser.new
database = getDatabase
dataset = database[TorrentLeechConfiguration::Table]

files.each do |file|
	counter += 1
	process = Float(counter) / files.size * 100.0
	printf("#{file.name} (%.2f%%)\n", process)
	html = Nil.readFile(file.path)
	releases = parser.processData(html)
	if releases.size == 25
		puts "Processing #{releases.size} releases"
	elsif releases.empty?
		puts 'Looks like a 404 document'
	else
		puts "*** WARNING: Detected a bad release count: #{releases.size} ***"
		#exit
	end
	releases.each do |release|
		dataset.where(site_id: release.siteId).delete
		insertData = release.getData
		begin
			dataset.insert(insertData)
		rescue Exception => exception
			puts "PostgreSQL error: #{exception.message}"
			puts insertData.inspect
			exit
		end
	end
end
