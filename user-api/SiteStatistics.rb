require 'json/JSONObject'

class SiteStatistics < JSONObject
  attr_reader :releaseCount, :totalSize

  def initialize(releaseCount, totalSize)
    super()
    @releaseCount = releaseCount
    @totalSize = totalSize
  end
end
