require 'cgi'
require 'sequel'

require 'nil/string'

require 'shared/timeString'
require 'shared/ReleaseData'
require 'shared/sizeString'

class TorrentLeechReleaseData < ReleaseData
  Debugging = false

  Targets =
    [
     ['Release', /<td id="torrentName" style="width:70%;">(.+?)<\/td>/, :name],
     ['Path', /<form action="(\/download\/.+?\/.+?\.torrent)" method="get">/, :path],
     ['Category', /<td><span class="label label-primary categorylabel">(.+?)<\/span><\/td>/, :category],
     ['Size', /<td class="label">Size<\/td><td>(.+?)<\/td>/, :sizeString],
     ['Release date', /<td class="label">Added<\/td>.*?<td>(.+?)<\/td>/m, :releaseDateString],
     ['Snatched', /<td class="label">Snatched<\/td><td>(\d+) times<\/td>/, :downloads],
     ['Seeders', /<td class="label">Peers<\/td><td>\d+ Peers \((\d+) Seeders and \d+ leechers\)<\/td>/, :seeders],
     ['Leechers', /<td class="label">Peers<\/td><td>\d+ Peers \(\d+ Seeders and (\d+) leechers\)<\/td>/, :leechers],
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
    @releaseDate = TorrentLeechReleaseData.parseDateString(@releaseDateString)
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
