require 'nil/file'

class UserShell
  def downloadTorrentFromSite(site, target)
    data = @api.prepareTorrentDownload(site, target)
    return false if data == nil
    puts "Attempting to queue release #{data[:name]} from #{site.name}..."
    @api.performTorrentDownload(site, data)
    return true
  end

  def downloadTorrentByName(name)
    @sites.each do |site|
      result = downloadTorrentFromSite(site, name)
      case result
      when false then next
      when true then return true
      end
    end
    return false
  end
end
