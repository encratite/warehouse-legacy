require 'configuration/Configuration'
require 'shared/database'

require 'Categoriser'

require 'nil/file'

database = getDatabase
categoriser = Categoriser.new(Configuration, database)
releases = Nil.readDirectory(Configuration::Torrent::Path::DownloadDone)
releases.each do |release|
	puts "Processing #{release.name}"
	categoriser.categorise(release.name)
end
