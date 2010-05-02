require 'nil/file'

shellGroup = 1005
userGroup = 1006

base = '/home/warehouse/user'
loginShell = '/bin/warehouse-shell'
sftpShell = '/bin/false'

lines = Nil.readLines '/etc/passwd'
lines.each do |line|
	tokens = line.split ':'
	puts "Skipping line \"#{line}\"" if tokens.size != 7
	user = tokens[0]
	groupId = tokens[3].to_i
	home = tokens[5]
	shell = tokens[6]
	
	expectedHome = base + '/' + user.gsub('-sftp', '')
	
	expectedShell = nil
	isTarget = false
	
	case groupId
	when shellGroup
		puts "Shell account #{user}"
		expectedShell = loginShell
		isTarget = true
	when userGroup
		puts "SFTP account #{user}"
		expectedShell = sftpShell
		isTarget = true
	else
		if line.index(base) != nil
			puts "Compromised: #{user}"
		end
	end
	
	if isTarget
		puts "Wrong home! It's #{home}, should be #{expectedHome}" if expectedHome != home
		puts "Wrong shell! It's #{shell}, should be #{expectedShell} " if expectedShell != shell
	end
end
