module Configuration
  module Torrent
    module Path
      UserBind = '/all'
      Filtered = 'filtered'
      Own = 'own'
      Manual = 'manual'

      User = '/home/warehouse/user'

      #need separate path constants for the setup script - otherwise they would be nil
      module RelativePaths
        Base = 'torrent'
        Torrent = "#{Base}/torrent"
        Download = "#{Base}/download"
        DownloadDone = "#{Base}/complete"
        Session = "#{Base}/session"
      end

      def self.setPaths
        RelativePaths.constants.each do |symbol|
          value = RelativePaths.const_get(symbol)
          value = Configuration::User.getPath(value)
          const_set(symbol, value)
        end
      end

      self.setPaths
    end
  end
end
