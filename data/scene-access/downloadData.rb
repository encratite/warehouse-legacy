require 'nil/file'
require 'nil/http'
require 'shared/sqlDatabase'
require 'configuration/Configuration'

def getHTTPHandler(configuration)
	data = configuration::SceneAccess::HTTP
	http = Nil::HTTP.new(data::Server, data::Cookies)
	return http
end

http = getHTTPHandler Configuration

(36..218).each do |page|
	while true
		path = "/archive.php?page=#{page}"
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
