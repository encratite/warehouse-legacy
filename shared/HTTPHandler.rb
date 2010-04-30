require 'net/http'

class HTTPHandler
	def initialize(uid, pass)
		@http = Net::HTTP.new('sceneaccess.org')
		
		@headers =
		{
			'User-Agent' => 'User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3',
			'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
			'Accept-Language' => 'en-us,en;q=0.5',
			#'Accept-Encoding' => 'gzip,deflate',
			'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
			'Cookie' => "uid=#{uid}; pass=#{pass}"
		}
	end
	
	def get(path)
		begin
			@http.request_get(path, @headers) do |response|
				response.value
				return response.read_body
			end
		rescue Net::HTTPError
			return nil
		rescue
			return nil
		end
	end
	
	def post(path, input)
		data = input.map { |key, value| "#{key}=#{value}" }
		postData = data.join '&'
		#puts "Post data: #{postData}"
		begin
			@http.request_post(path, postData, @headers) do |response|
				response.value
				return response.read_body
			end
		rescue Net::HTTPError
			return nil
			
		rescue Errno::ETIMEDOUT
			return nil
			
		rescue Errno::ECONNRESET
			return nil
			
		rescue Net::HTTPFatalError
			return nil
		rescue
			return nil
		end
	end
end
