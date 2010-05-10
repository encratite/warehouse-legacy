require 'configuration/Configuration'
require 'shared/database'

require 'category/Categoriser'

require 'nil/file'

database = getDatabase
categoriser = Categoriser.new(Configuration, database)
data = Nil.readDirectory(Configuration::Torrent::Path::DownloadDone)
releases.each do |release|
	puts "Processing #{release.name}"
	categoriser.categorise(release.name)
end
