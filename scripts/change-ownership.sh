#!/usr/bin/ruby

require 'etc'
require 'fileutils'

def getUserGroup(user)
	begin
		userData = Etc.getpwnam(user).gid
		groupName = Etc.getgrgid(userData).name
		return groupName
	rescue ArgumentError
		return nil
	end
end

def error
	exit 1
end

superUser = 'root'
group = 'warehouse-shell'

effectiveUser = Etc.getpwuid(Process::Sys.geteuid).name
if effectiveUser != superUser
	puts 'This script requires root privileges. (setuid flag)'
	error
end

if ARGV.size != 2
	puts 'Usage:'
	puts "#{__FILE__} <user> <path>"
	error
end

user, path = ARGV

#root chowning is not permitted
if user == superUser
	puts 'You may not give root ownership to a file.'
	error
end

#check if the user in question is in the target group
userGroup = getUserGroup(user)
if userGroup == nil
	puts "No such user: #{user}"
	error
end

if userGroup != group
	puts "Group mismatch: #{userGroup} != #{group}"
	error
end

begin
	FileUtils.chown(user, group, path)
rescue Errno::ENOENT
	puts "No such file: #{path}"
	error
end
