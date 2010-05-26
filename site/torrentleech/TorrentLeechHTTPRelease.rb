require 'shared/http/HTTPRelease'
require 'shared/sizeString'

require 'cgi'

class TorrentLeechHTTPRelease < HTTPRelease
	def initialize(data, symbols)
		super(data, symbols)
		@name = CGI::unescapeHTML(@name)
		@siteId = @siteId.to_i
	end
end
