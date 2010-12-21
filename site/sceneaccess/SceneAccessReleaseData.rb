require 'nil/string'

require 'shared/timeString'
require 'shared/ReleaseData'

require 'cgi'

class SceneAccessReleaseData < ReleaseData
  Debugging = false

  Targets =
    [
     ['Release', /<h1>(.+?)<\/h1>/, :name],
     ['ID', /<a class="index" href="download\/(\d+)/, :id],
     #info hashes are no longer available
     #['Info hash', /<td valign=\"top\" align=left>(.+?)<\/td>/, :infoHash],
     #pre-time no longer available (wtf?)
     #['Pre-time', />Pre Time<\/td>.+?>(.+?)<\/td>/, :preTimeString],
     ['Section', />Type<\/td>.+>(.+)<\/td>/, :section],
     ['Size', />Size<\/td>.+?\((.+?) bytes/, :sizeString],
     ['Date', />Added<\/td>.+?>(.+?)</, :date],
     #no longer available either
     #['Hits', />Hits<\/td>.+?>(\d+)</, :hits],
     ['Downloads', />Snatched<\/td>.+?>(\d+) time\(s\)/, :downloads],
     ['Files', /<td class="td_col">(\d+) files?<\/td>/, :files],
     ['Seeders', />(\d+) seeder\(s\)/, :seeders],
     ['Leechers', /, (\d+) leecher\(s\)/, :leechers],
     ['Torrent path', /<a class="index" href="(download\/.+?\.torrent)">/, :path],
     ['NFO', /<tr><td class="td_head">Description<\/td><td class="td_col"><br \/>([\s\S]+?)<\/td><\/tr>/, :nfo, false],
    ]

  def removeHTMLLinks(input)
    output = input.gsub(/<a .+?>(.+?)<\/a>/) { |match| $1 }
    return output
  end

  def postProcessing(input)
    #@preTime = parseTimeString @preTimeString
    @preTime = nil

    size = @sizeString.gsub(',', '')
    if !size.isNumber
      errorMessage = "Invalid file size specified: #{@sizeString}"
      raise Error.new(errorMessage)
    end
    @size = size.to_i

    @id = @id.to_i
    @hits = @hits.to_i
    @downloads = @downloads.to_i
    @seeders = @seeders.to_i
    @leechers = @leechers.to_i

    @path = "/#{@path}" if !@path.empty? && @path[0] != '/'

    if @nfo != nil
      @nfo = @nfo.gsub('<br />', '')
      @nfo = @nfo.gsub('&nbsp;', ' ')
      @nfo = CGI::unescapeHTML(@nfo)
      @nfo = removeHTMLLinks(@nfo)
    end

    if Debugging
      puts "Size: #{@size}"
      puts "Pre-time in seconds: #{@preTime.inspect}"
      puts "NFO: #{@nfo}"
    end

    @infoHash = nil
    @hits = nil
  end

  def getData
    return {
      site_id: @id,
      torrent_path: @path,
      section_name: @section,
      name: @name,
      nfo: @nfo,
      info_hash: @infoHash,
      pre_time: @preTime,
      file_count: @files,
      release_date: @date,
      release_size: @size,
      hit_count: @hits,
      download_count: @downloads,
      seeder_count: @seeders,
      leecher_count: @leechers
    }
  end
end
