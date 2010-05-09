$: += ['shared', 'site']

require 'nil/file'
require 'database'
require 'HTTPHandler'
require 'Configuration'

def getHTTPHandler(configuration)
	data = configuration::TorrentVault::HTTP
	http = HTTPHandler.new(data::Server, data::Cookies)
	return http
end

http = getHTTPHandler Configuration

(1..826).each do |page|
	while true
		path = "/torrents.php?page=#{page}&order_by=s3&order_way=DESC"
		data = http.get(path)
		if data == nil
			puts "Failed to retrieve #{path}"
		else
			puts "Successfully retrieved #{path}"
			Nil.writeFile("output/#{page}", data)
			break
		end
	end
end
