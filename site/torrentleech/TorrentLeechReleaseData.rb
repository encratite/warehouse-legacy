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
     ['Release', /<td class="label">Torrent Name<\/td><td>(.+?)<\/td>/, :name],
     ['Path', /<form action="(\/download\/\d+\/.+?\.torrent)" method="get">/, :path],
     #info hash is no longer available
     #['Info hash', /<td valign="top" align=left>(.+?)<\/td>/, :infoHash],
     ['Category', /<td class="label">Category<\/td><td>(.+?)<\/td>/, :category],
     #this requires some parsing
     ['Size', /<td class="label">Size<\/td><td>(.+?)<\/td>/, :sizeString],
     #same here
     ['Release date', /<td class="label">Added<\/td><td>(.+?)<\/td>/, :releaseDateString],
     ['Snatched', /<td class="label">Snatched<\/td><td>(\d+) times<\/td>/, :downloads],
     ['Seeders', /<span class="uploaded"><b>Seeders:<\/b><\/span> (\d+)/, :seeders],
     ['Leechers', /<span class="downloaded"><b>Leechers:<\/b><\/span> (\d+)/, :leechers],
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
    pattern = /.+? (\d+).+? (.+?) (\d+) (\d+):(\d+):(\d+) (.+?)/
    match = pattern.match(input)
    return nil if match == nil
    day = match[1].to_i
    monthString = match[2]
    year = match[3].to_i
    hour = match[4].to_i
    minute = match[5].to_i
    second = match[6].to_i
    ampm = match[7]
    if ampm == 'PM'
      hour += 12
    end

    months =
      [
       'January',
       'February',
       'March',
       'April',
       'June',
       'July',
       'August',
       'September',
       'October',
       'November',
       'December',
      ]

    index = months.index(monthString)
    return nil if index == nil

    month = index + 1

    output = Time.gm(year, month, day, hour, minute, second)
    return output
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
