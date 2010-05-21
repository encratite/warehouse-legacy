require 'shared/HTTPRelease'
require 'shared/sizeString'

class TorrentLeechFullHTTPRelease < HTTPRelease
	def initialize(data, symbols)
		super(data, symbols)
		@name = @name.gsub(' ', '.')
		@siteId = @siteId.to_i
		@commentCount = @commentCount.to_i
		@size = convertSizeString("#{@size} #{@sizeUnit}")
		if @size == nil
			raise Error.new("Unable to parse size string \"#{sizeString}\"")
		end
	end
	
	def getData
		output =
		{
			site_id: @siteId,
			torrent_path: @torrentPath,
			info_hash: nil,
			section_name: @category,
			name: @name,
			nfo: nil,
			release_date: @date,
			release_size: @size,
			comment_count: @commentCount,
			download_count: @downloads,
			seeder_count: @seeders,
			leecher_count: @leechers,
			uploader: @uploader,
		}
		
		return output
	end
end
