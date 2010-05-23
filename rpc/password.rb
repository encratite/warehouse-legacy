def isValidLogin(user, password)
	IO.popen('verify-login visible', mode = 'r+') do |io|
		io.write "#{user}:#{password}"
		io.close_write
		io.read
	end
	return $?.to_i == 0
end
