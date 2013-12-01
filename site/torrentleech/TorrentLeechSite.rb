require 'shared/http/HTTPReleaseSite'

class TorrentLeechSite < HTTPReleaseSite
  def initialize(siteData, torrentData, connections, configuration)
    super(siteData, torrentData, connections, configuration)
    @httpData = siteData::HTTP
  end

  def login
    postData = {
      'login' => 'submit',
      'password' => @httpData::Password,
      'remember_me' => 'on',
      'username' => @httpData::Username,
    }
    @httpHandler.post('/user/account/login/', postData)
  end

  def browse(retrying = false)
    data = @httpHandler.get(@browsePath)
    if data == nil
      output "Error: Failed to retrieve #{@browsePath}"
      return
    end

    releases = @htmlParser.processData(data)
    if releases.empty?
      output "Error: Failed to retrieve any releases from #{@browsePath}"
      if retrying
        output 'Aborted'
      else
        output 'Logging in and trying again'
        login
        browse(true)
      end
      return
    end
    output "Retrieved #{releases.size} releases from #{@browsePath}"
    releases.each do |release|
      result = @dataset.where(site_id: release.siteId)
      #check if this release is already in the database
      next if !result.empty?
      processNewRelease release
    end
  end

  def processNewRelease(release)
    name = release.name
    idString = release.siteId.to_s
    detailsPath = sprintf(@detailsPath, idString)
    output "Discovered a new release: #{name} (ID: #{release.siteId})"
    sleep @downloadDelay
    @releaseHandler.processReleasePath(name, detailsPath)
  end
end
