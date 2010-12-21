class IRCRegexp
  attr_reader :release, :url

  def initialize(release, url)
    @release = release
    @url = url
  end
end
