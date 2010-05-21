require 'cgi'

def extractNameFromTorrent(input)
	match = /download\.php\/\d+\/(.+?)\.torrent/.match(input)
	raise "Failed to get a match for the name pattern in the torrent path: #{input}" if match == nil
	name = match[1]
	name = CGI.unescapeHTML(name)
	name = CGI.unescape(name)
	name.force_encoding 'IBM437'
	name = name.encode('UTF-8')
	return name
end
