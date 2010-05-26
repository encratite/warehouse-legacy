require 'digest/sha2'

require 'nil/file'

require 'configuration/TorrentLeech'

require 'shared/database'
require 'shared/html/HTTPHandler'

def getHTTPHandler(configuration)
	data = TorrentLeechConfiguration::HTTP
	http = HTTPHandler.new(data::Server, data::Cookies)
	return http
end

http = getHTTPHandler Configuration

(0..1095).each do |page|
	while true
		path = "/browse.php?page=#{page}"
		data = http.get(path)
		if data == nil
			puts "Failed to retrieve #{path}"
		else
			hash = Digest::SHA256.hexdigest(data)
			filePath = "html/torrentleech/#{hash}"
			puts "Successfully retrieved #{path}, writing data to #{filePath}"
			Nil.writeFile(filePath, data)
			break
		end
	end
	sleep 3
end
