require 'shared/http/HTTPRelease'

class TorrentLeechHTTPRelease < HTTPRelease
  def initialize(data)
    @siteId = data["fid"].to_i
    @name = data["name"]
  end
end
