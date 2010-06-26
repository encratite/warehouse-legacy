require 'etc'
require 'fileutils'

require 'nil/file'

require 'configuration/Configuration'

require 'shared/sqlDatabase'

def rootCheck
	if Process.euid != 0
		raise 'You need to run this script as root.'
	end
end

def createGroups(groups)
	groups.each do |group|
		`groupadd #{group}`
		if $?.to_i == 0
			puts "Created group #{group}"
		else
			puts "Group #{group} already exists"
		end
	end
end

def createUser(user)
	if user == nil || user.empty? || user == 'root'
		#check because of the passwd line which needs to be run as root - dangerous because the password of the root account would be changed otherwise
		raise 'Invalid user name'
	end
	begin
		passwordData = Etc.getpwnam(user)
	rescue ArgumentError
		puts "Creating warehouse user #{user}"
		`useradd #{user}`
		puts "Please specify a password for user #{user}:"
		`passwd #{user}`
	end
end

def createDirectory(directory, user = nil, group = nil, mode = nil)
	if File.exists?(path)
		puts "Directory #{path} already exists"
	else
		puts "Creating directory #{path}"
		if user != nil && group != nil
			puts "Changing the ownership of #{path} to #{user}:#{group}"
			FileUtils.chown(user, group, path)
		end
		if mode != nil
			modeString = sprintf('0%o', mode)
			puts "Changing the mode of #{path} to #{modeString}"
		end
	end
end

def initialiseSQLUserAndDatabase(user, database)
	#this works for PostgreSQL with a standard setup only
	commandLine = 'su -c - postgres psql'
	begin
		IO.popen(commandLine, 'r+') do |pipe|
		
			pipe.puts "create role #{user};"
			output = pipe.readline
			if output == 'CREATE ROLE'
				puts "Created SQL user #{user}"
			elsif output.include?('already exists')
				puts "SQL user #{user} already exists"
			else
				raise "SQL user creation error: #{output}"
			end
			
			pipe.puts "create database #{database} with owner #{user};"
			output = pipe.readline
			if output == 'CREATE DATABASE'
				puts "Created database #{database}"
			elsif output.include?('already exists')
				puts "Database #{database} already exists"
			else
				raise "SQL database creation error: #{output}"
			end
		end
	rescue EOFError
		raise 'psql execution failed'
	rescue Errno::ENOENT
		raise "Unable to execute \"#{commandLine}\" - no such path"
	end
end

def getSQLStatements(script)
	lines = Nil.readLines(script)
	
	#get rid of the comments
	lines.map! do |line|
		#not exactly the right way to do it put it'll do the job for now
		tokens = line.split('--')
		tokens[0]
	end
	
	#this is improper, too
	replacements =
	[
		[/[\r\t]/, ''],
		['( ', '('],
		[' )', ')'],
	]
	data = lines.join(' ')
	replacements.each do |target, replacement|
		data.gsub!(target, replacement)
	end
	
	statements = data.split(';')
	return statements
end

def createTables(script)
	database = getSQLDatabase
	statements = getSQLStatements
	statements.each do |statement|
		#this actually deletes existing tables - possibly not a good idea...
		puts "Executing #{statement}"
		database[statement]
	end
end

def runSetup
	userData = Configuration::User
	
	rootCheck
	
	groups =
	[
		userData::ShellGroup,
		userData::SFTPGroup
	]
	createGroups(groups)
	
	user = userData::WarehouseUser
	userGroup = Etc.getgrgid(Etc.getpwnam(user).gid).name
	createUser(user)
	
	pathData = Configuration::Torrent::Path
	relativePathData = pathData::RelativePaths
	
	directoryData =
	{
		#torrent directory must be writable for the warehouse users so the shell processes can write new torrents to the directory
		Torrent: [user, userData::ShellGroup, 0775],
		
		#only regular ownership required for the other torrent directories
		Download: [user, userGroup],
		DownloadDone: [user, userGroup],
	}
	
	#convert the symbols to actual paths
	directories = []
	directoryData.each do |symbol, permissions|
		path = Configuration::User.getPath(relativePathData.const_get(symbol))
		entry = [symbol] + permissions
		directories << entry
	end
	
	#add the warehouse user directory which is to remain root:root
	directories << [pathData::User]
	
	#attempt to create the directories with the appropriate permissions
	directories.each do |entry|
		createDirectory(*entry)
	end
	
	sqlData = Configuration::SQLDatabase
	initialiseSQLUserAndDatabase(sqlData::User, sqlData::SQLDatabase)
	createTables(sqlData::Script)
end

begin
	runSetup
rescue RuntimeError => error
	puts "Error: #{error.message}"
end
