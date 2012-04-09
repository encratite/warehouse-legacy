class TorrentVaultHTTP
  def initialize(siteData)
    http = siteData::HTTP
    @httpHandler = Nil::HTTP.new(http::Server, http::Cookies)
    @httpHandler.ssl = http::SSL
    @user = http::User
    @password = http::Password
  end

  def isInvalidData(data)
    if data.index('You will be banned') != nil
      return true
    end
    return ['', nil].include?(data)
  end

  def get(path)
    data = @httpHandler.get(path)
    if isInvalidData(data)
      loginData = {
        'username' => TorrentVaultConfiguration::HTTP::User,
        'password' => TorrentVaultConfiguration::HTTP::Password,
        'login' => 'Log In!',
      }
      @httpHandler.post('/login.php', loginData)
      data = @httpHandler.get(path)
      if isInvalidData(data)
        raise "Unable to log in to retrieve path #{path}"
      end
    end
    return data
  end
end
