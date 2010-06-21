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

def createDirectories(directories)
	directories.each do |path|
		if File.exists?(path)
			puts "Directory #{path} already exists"
		else
			puts "Creating directory #{path}"
		end
	end
end

def getSQLStatements(script)
	lines = Nil.readLines(script)
	lines.map! do |line|
		
	end
end

def createTables(script)
	database = getSQLDatabase
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
	
	createUser(userData::WarehouseUser)
	
	pathData = Configuration::Torrent::Path
	relativePathData = pathData::RelativePaths
	
	#torrent directories
	directories = relativePathData.constants.map do |symbol|
		Configuration::User.getPath(relativePathData.const_get(symbol))
	end
	#warehouse user directory
	directories << pathData::User
	
	createDirectories(directories)
	
	#
	createTables(Configuration::SQLDatabase::Script)
end

begin
	runSetup
rescue RuntimeError => error
	puts "Error: #{error.message}"
end
