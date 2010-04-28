require 'HTTPHandler'
require 'Configuration'

http = HTTPHandler.new(Configuration::Cookie::Uid, Configuration::Cookie::Pass)

data = http.get('/browse.php')
if data == nil
	puts 'Error'
	return
end
puts data
