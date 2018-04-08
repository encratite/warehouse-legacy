require 'time'

require 'shared/http/HTTPRelease'
require 'shared/sizeString'

require 'site/torrentleech/extractName'

class TorrentLeechFullHTTPRelease < HTTPRelease
  def initialize(data)
    @siteId = data["fid"].to_i
    @size = data["size"]
    @seeders = data["seeders"]
    @leechers = data["leechers"]
	filename = data["filename"]
    @torrentPath = "/download/#{@siteId}/#{filename}"
    @name = data["name"]
	categories =
	{
      8 => "Cam",
      9 => "TS/TC",
      11 => "DVDRip/DVDScreener",
      12 => "DVD-R",
      13 => "Bluray",
      14 => "BlurayRip",
      15 => "Boxsets",
      16 => "Music videos",
      17 => "PC",
      18 => "XBOX",
      19 => "XBOX360",
      20 => "PS2",
      21 => "PS3",
      22 => "PSP",
      23 => "PC-ISO",
      24 => "Mac",
      25 => "Mobile",
      26 => "Episodes",
      27 => "Boxsets",
      28 => "Wii",
      29 => "Documentaries",
      30 => "Nintendo DS",
      31 => "Audio",
      32 => "Episodes HD",
      33 => "0-day",
      34 => "Anime",
      35 => "Cartoons",
      36 => "Movies",
      37 => "WEBRip",
      38 => "Education",
      39 => "PS4",
      40 => "XBOXONE",
      41 => "4K Upscaled",
      42 => "Mac",
      43 => "HDRip",
      44 => "TV Series",
      45 => "EBooks",
      46 => "Comics",
      47 => "Real 4K"
	}
	@category = categories[data["categoryID"]]
	timestamp = data["addedTimestamp"]
	@date = Time.at(timestamp).utc.to_datetime
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
      comment_count: nil,
      download_count: nil,
      seeder_count: @seeders,
      leecher_count: @leechers,
      uploader: nil,
    }

    return output
  end
end
