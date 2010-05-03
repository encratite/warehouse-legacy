$:.concat ['../shared', '../manager']

require 'nil/file'
require 'database'
require 'HTTPHandler'
require 'Configuration'

def getHTTPHandler(configuration)
	http = HTTPHandler.new(configuration::SceneAccess::Cookie::UId, configuration::SceneAccess::Cookie::Pass)
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
