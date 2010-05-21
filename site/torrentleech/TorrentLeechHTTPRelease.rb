require 'shared/HTTPRelease'
require 'shared/sizeString'

class TorrentLeechHTTPRelease < HTTPRelease
	def initialize(data, symbols)
		super(data, symbols)
		@name = @name.gsub(' ', '.')
		@siteId = @siteId.to_i
	end
end
