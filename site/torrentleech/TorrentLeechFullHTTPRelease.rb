require 'shared/HTTPRelease'
require 'shared/sizeString'

class TorrentLeechHTTPRelease < HTTPRelease
	def initialize(data, symbols)
		super(data, symbols)
		@name = @name.gsub(' ', '.')
		@siteId = @siteId.to_i
		@commentCount = @commentCount.to_i
		@size = convertSizeString(@size)
		if @size == nil
			raise Error.new("Unable to parse size string \"#{sizeString}\"")
		end
	end
end
