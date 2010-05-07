def processData(data)
	output = data.gsub(/<a .+?>(.+?)<\/a>/) do |match|
		puts "Match: #{match.inspect}"
		$1
	end
	return output
end

data = "URL: <a href=\"http://www.tvrage.com/Intervention\">http://www.tvrage.com/Intervention</a>"
data += data
puts processData(data)
