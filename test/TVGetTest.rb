$: << '.'

require 'configuration/TorrentVault'
require 'secret/TorrentVault'
require 'nil/http'

http = Nil::HTTP.new(TorrentVaultConfiguration::HTTP::Server, TorrentVaultConfiguration::HTTP::Cookies)
http.ssl = true
loginData = {
  'username' => TorrentVaultConfiguration::HTTP::User,
  'password' => TorrentVaultConfiguration::HTTP::Password,
  'login' => 'Log In!',
}
http.post('/login.php', loginData)
puts http.get('/torrents.php').inspect
