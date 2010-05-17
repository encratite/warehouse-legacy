require 'fileutils'

require 'nil/console'
require 'nil/string'
require 'nil/file'

require 'shell/Timer'
require 'shell/SearchResult'

class UserShell
	def commandHelp
		puts 'List of available commands:'
		sortedCommands = Commands.sort { |a, b| a[0] <=> b[0] }
		names = sortedCommands.map { |x| x[0] }
		maximum = 0
		names.each do |names|
			maximum = names.size if names.size > maximum
		end
		sortedCommands.each do |name, description, symbol|
			name += ' ' * (maximum - name.size)
			puts "#{Nil.white name} - #{description}"
		end
	end
	
	def commandAddFilter(type)
		if @argument.empty?
			warning 'Please specify a filter to add.'
			return
		end
		filter = @argument
		if filter.size > @filterLengthMaximum
			error "Your filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		if @filters.where(user_id: @user.id).count > @filterCountMaximum
			error "You have too many filters (#{filterCountMaximum})."
			return
		end
		
		#check if it is a valid regular expression first
		@database["select 1 where '' ~* ?", @argument].all
		@filters.insert(user_id: @user.id, filter: filter, release_filter_type: type.to_s)
		success "Your filter has been added."
	end
	
	def commandAddNameFilter
		commandAddFilter(:name)
	end
	
	def commandAddNFOFilter
		commandAddFilter(:nfo)
	end
	
	def commandAddGenreFilter
		commandAddFilter(:genre)
	end
	
	def commandListFilters
		filterTypeDescriptions =
		{
			'name' => nil,
			'nfo' => [:lightGreen, 'NFO filter'],
			'genre' => [:pink, 'MP3 genre filter'],
		}
		filters = @filters.where(user_id: @user.id).order(:id).select(:filter, :category, :release_filter_type)
		if filters.empty?
			puts 'You currently have no filters.'
			return
		end
		puts Nil.white('This is a list of your filters:')
		counter = 1
		filters.each do |filter|
			category = filter[:category]
			type = filter[:release_filter_type]
			info = "#{counter.to_s}. #{filter[:filter]}"
			filterTypeDescription = filterTypeDescriptions[type]
			if filterTypeDescription != nil
				colourSymbol, description = filterTypeDescription
				info += " #{Nil.method(colourSymbol).call("[#{description}]")}"
			end
			info += " #{Nil.lightRed "[#{category}]"}" if category != nil
			puts info
			counter += 1
		end
	end

	def commandDeleteFilter
		if @arguments.empty?
			warning 'Please specify the index of a filter to delete.'
			return
		end
		
		@database.transaction do
			ids = convertFilterIndices(@arguments)
			return if ids == nil
			
			ids.each { |id| @filters.where(id: id).delete }
		end
		
		if @arguments.size == 1
			puts 'The filter has been removed.'
		else
			puts 'The filters have been removed.'
		end
	end
	
	def commandClearFilters
		@filters.where(user_id: @user.id).delete
		puts 'All your filters have been removed.'
	end
	
	def commandDatabase
		timer = Timer.new
		queryCount = 0
		@sites.each do |site|
			siteName = site.name
			table = @database[site.table]
			
			data =
			[
				['Number of releases in the database', table.count.to_s],
				['Size of releases available on demand', Nil.getSizeString(table.sum(:release_size))],
			]
			
			puts "#{stringColour(siteName)}:"
			printData data
			print "\n"
			queryCount += 2
		end
		delay = timer.stop
		success "Executed #{queryCount} queries in #{delay} ms."
	end
	
	def commandSearch
		if @argument.empty?
			warning "Specify a regular expression to look for."
			return
		end
		
		if @argument.size > @filterLengthMaximum
			error "Your search filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		
		timer = Timer.new
		
		siteResults = {}
		count = 0
		@sites.each do |site|
			table = site.table.to_s
			abbreviation = site.abbreviation
			results = @database["select site_id, section_name, name, release_date, release_size from #{table} where name ~* ? order by site_id desc limit ?", @argument, @searchResultMaximum].all
			siteResults[abbreviation] = results
			count += results.size
		end
		
		delay = timer.stop
		
		if count == 0
			warning 'Your search yielded no results.'
			return
		end
		
		searchResults = {}
		@sites.each do |site|
			abbreviation = site.abbreviation
			
			results = siteResults[abbreviation]
			results.each do |result|
				name = result[:name]
				if searchResults[name] == nil
					searchResults[name] = SearchResult.new(abbreviation, result)
				else
					searchResults[name].processData(abbreviation, result)
				end
			end
		end
		
		resultArray = searchResults.values
		resultArray.sort do |x, y|
			x.id <=> y.id
		end
		
		resultArray.each do |result|
			puts result.getString
		end
		
		if count == 1
			success "Found one result in #{delay} ms."
		else
			success "Found #{count} results in #{delay} ms."
		end
	end
	
	def commandDownload
		target = @argument
		
		if target.empty?
			warning "You have not specified a release to download."
			return
		end
		
		@sites.each do |site|
			result = downloadTorrent(site, target)
			case result
				when false then next
				when true then return
				when nil then return
			end
		end
		
		error "Unable to find release \"#{target}\"."
	end
	
	def commandDownloadByID
		if @arguments.size != 2
			warning 'Invalid argument count - you need to specify a site and the ID of the release.'
			return
		end
		
		abbreviation = @arguments[0]
		id = @arguments[1]
		if !id.isNumber
			error 'You have specified an invalid ID.'
			return
		end
		
		id = id.to_i
		
		offset = @sites.index(abbreviation)
		if offset == nil
			error "Unable to find site \"#{abbreviation}\"."
			return
		end
		
		site = @sites[offset]
		result = downloadTorrent(site, id)
		if result == false
			error 'You have specified an invalid ID.'
			return
		end
	end
	
	def commandStatus
		puts 'Status of the server:'
		
		freeSpace = Nil.getSizeString(Nil.getFreeSpace(@torrentPath))
		speedString = Nil.getDeviceSpeedStrings(@nic)
		
		data =
		[
			['Free space left on device', freeSpace],
			['Download speed', speedString[0]],
			['Upload speed', speedString[1]],
		]
		
		printData data
	end
	
	def commandCancel
		forbidden = ['..', '/']
		if @arguments.empty?
			warning 'You need to specify a release whose download you wish to cancel.'
			return
		end
		filename = @argument + '.torrent'
		forbidden.each do |illegalString|
			if filename.index(illegalString) != nil
				error 'You have specified an invalid release name.'
				return
			end
		end
		torrent = Nil.joinPaths(@torrentPath, filename)
		begin
			stat = File.stat(torrentPath)
			user = Etc.getpwuid(stat.uid).name
			if user != @user.name
				error "#{filename} is owned by another user - ask the administrator for help."
				return
			end
			FileUtils.rm(torrent)
			success "#{filename} has been removed successfully."
		rescue Errno::EACCES
			error "You do not have the permission to remove #{filename}."
		rescue Errno::ENOENT
			error "Unable to find #{filename}."
		end
	end
	
	def commandExit
		puts Nil.lightGreen('See you.')
		#sleep 1
		exit
	end

	def commandPermissions
		if @user.isAdministrator
			userLevel = 'Administrator'
		else
			userLevel = 'Regular user'
		end
		
		sizeLimitString = Nil.getSizeString @releaseSizeLimit
		
		data =
		[
			['User level', userLevel],
			['Size limit per release', sizeLimitString],
			['Search result limit per site', @searchResultMaximum.to_s],
		]
		
		printData data
	end
	
	def commandSSH
		if @argument.size >= @sshKeyMaximum
			error "Your SSH data exceeds the maximal length of #{@sshKeyMaximum}."
			return
		end
		if @arguments.size < 2 || @arguments.index("\n") != nil
			error "Your SSH data does not fit the following pattern: ssh-(rsa|dsa) data [comment]"
			return
		end
		type = @arguments[0]
		if !['ssh-rsa', 'ssh-dsa'].include?(type)
			error "Unknown SSH key type: #{type}"
			return
		end
		sshDirectory = "/home/warehouse/user/#{@user.name}/.ssh"
		begin
			FileUtils.mkdir(sshDirectory)
		rescue Errno::EEXIST
		rescue Errno::ENOENT
			error 'Unable to create the directory - please contract the administrator'
			return
		end
		FileUtils.chmod(0700, sshDirectory)
		keysFile = "#{sshDirectory}/authorized_keys"
		Nil.writeFile(keysFile, @argument + "\n")
		FileUtils.chmod(0600, keysFile)
		success 'Your SSH key has been changed.'
	end
	
	def commandRegexpHelp
		puts "Here is a list of examples:"
		puts ''
		maximum = 0
		padEntries(RegexpExamples).each do |example|
			expression = example[0]
			description = example[1]
			puts "#{Nil.white expression} - #{description}"
		end
		puts "\nSearches are #{Nil.white 'case insensitive'} by default."
		puts "This system permits you to create case sensitive expressions using the overriding #{Nil.white '(?c)'} prefix."
	end
	
	def commandCategory
		if @arguments.size < 2
			warning 'Invalid argument count - the path and at least one filter index are required.'
			return
		end
		category = @arguments[0]
		indices = @arguments[1..-1]
		if category.index('..') != nil
			error 'You have specified an invalid folder.'
			return
		end
		
		@database.transaction do		
			ids = convertFilterIndices(indices)
			return if ids == nil
			ids.each do |id|
				@filters.where(id: id).update(category: category)
			end
		end
		
		if indices.size == 1
			success "Assigned category #{category} to one filter."
		else
			success "Assigned category #{category} to #{indices.size} filters."
		end
	end
	
	def commandDeleteCategory
		if @arguments.size != 1
			warning 'Invalid argument count - you need to specify the path to a category to remove.'
			return
		end
		
		category = @argument
		
		if category.index('..') != nil
			error 'You have specified an invalid path.'
			return
		end
		
		path = Nil.joinPaths(@filteredPath, category)
		begin
			FileUtils.rm_r(path)
			success "Removed category \"#{category}\""
		rescue Errno::ENOENT
			error "Unable to find category \"#{category}\" in your folder."
		end
	end
end
