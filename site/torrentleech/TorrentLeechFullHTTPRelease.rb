require 'shared/HTTPRelease'
require 'shared/sizeString'

require 'site/torrentleech/extractName'

class TorrentLeechFullHTTPRelease < HTTPRelease
	def initialize(data, symbols)
		super(data, symbols)
		@siteId = @siteId.to_i
		@commentCount = @commentCount.to_i
		@size = convertSizeString("#{@size} #{@sizeUnit}")
		if @size == nil
			raise Error.new("Unable to parse size string \"#{sizeString}\"")
		end
		@downloads = @downloads.gsub(',', '').to_i
		@seeders = @seeders.to_i
		@leechers = @leechers.to_i
		
		@torrentPath = "/#{@torrentPath}"
		
		#the original @name is actually being ignored - this site is too much of a mess
		@name = extractNameFromTorrent(@torrentPath)
		puts "Debug: #{@name} (#{@name.inspect})"
		
		match = />([^><]+)</.match(@uploader)
		if match != nil
			@uploader = match[1]
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
