require 'cgi'
require 'sequel'
require 'time'

require 'nil/string'

require 'shared/timeString'
require 'shared/ReleaseData'
require 'shared/sizeString'

class TorrentLeechReleaseData < ReleaseData
  Debugging = false

  Targets =
    [
     ['Release', /<h2 id="torrentnameid" class="mb-20 text-center page-heading">(.+)?<\/h2>/, :name],
     ['Path', /<a id="detailsDownloadButton" class="btn tl-btn btn-success" title="Download Torrent" href="(\/download\/.+?)">Download Torrent<\/a>/, :path],
     ['Category', /<tr><td class="description">Category<\/td><td>(.+?)<\/td><\/tr>/, :category],
     ['Size', /<tr><td class="description">Size<\/td><td>(.+?)<\/td><\/tr>/, :sizeString],
     ['Release date', /<tr><td class="description">Added<\/td>\s*<td>(.+?)<strong>/m, :releaseDateString],
     ['Downloaded', /<tr><td class="description">Downloaded<\/td><td>(\d+) times<\/td><\/tr>/, :downloads],
     ['Seeders', /<tr><td class="description">Seeders<\/td><td><span class="seeders-text">(\d+)/, :seeders],
     ['Leechers', /<tr><td class="description">Leechers<\/td><td><span class="leechers-text">(\d+)/, :leechers],
     ['ID', /<input type="hidden" name="torrentID" value="(\d+)">/, :id],
    ]

  def postProcessing(input)
    puts @path
    pathTokens = @path.split('/')
    if pathTokens.empty?
      raise Error.new("Invalid path: #{@path}")
    end
    lastToken = pathTokens[-1]
    lastToken.replace(CGI.escape(lastToken))
    @path = pathTokens.join('/')
    @id = @id.to_i
    @size = convertSizeString(@sizeString)
    @releaseDate = Time.parse(@releaseDateString + " UTC")
    if @releaseDate == nil
      raise Error.new("Unable to parse date string: #{@releaseDateString.inspect}")
    end
    @downloads = @downloads.to_i
    @seeders = @seeders.to_i
    @leechers = @leechers.to_i

    @path = "/#{@path}" if !@path.empty? && @path[0] != '/'

    #minor adjustment
    @name = @name.gsub(' ', '.')

    #releaseDate requires some parsing here
  end

  def self.parseDateString(input)
    begin
      return Date.parse(input)
    rescue
      return nil
    end
  end

  def getData
    return {
      site_id: @id,
      torrent_path: @path,
      info_hash: @infoHash,
      section_name: @category,
      name: @name,
      #not sure what to do about the lack of NFO data now - it's all mixed...
      nfo: nil,
      release_date: @releaseDate,
      release_size: @size,
      #no longer available,
      file_count: nil,
      #screw it
      comment_count: nil,
      download_count: @downloads,
      seeder_count: @seeders,
      leecher_count: @leechers,
      #no longer available
      uploader: nil,
    }
  end
end
