require_relative 'configuration/Configuration'
require_relative 'shared/sqlDatabase'

require_relative 'category/Categoriser'

require 'nil/file'

database = getSQLDatabase
categoriser = Categoriser.new(Configuration, database)
releases = Nil.readDirectory(Configuration::Torrent::Path::DownloadDone)
releases.each do |release|
	puts "Processing #{release.name}"
	categoriser.categorise(release.name)
end
