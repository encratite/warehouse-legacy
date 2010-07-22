require 'fileutils'

require 'nil/console'
require 'nil/string'
require 'nil/file'
require 'nil/network'

require 'shared/Timer'

require 'user-api/SearchResult'

class UserShell
	def commandHelp
		puts 'List of available commands:'
		sortedCommands = Commands.sort { |a, b| a[0] <=> b[0] }
		names = sortedCommands.map { |x| x[0] }
		maximum = 0
		names.each do |names|
			maximum = names.size if names.size > maximum
		end
		sortedCommands.each do |command|
			name, description, symbol = command
			next if !hasAccess(command)
			name += ' ' * (maximum - name.size)
			puts "#{Nil.white name} - #{description}"
		end
	end
	
	def commandAddFilter(type)
		filter = @argument
		if filter.empty?
			warning 'Please specify a filter to add.'
			return
		end
		@api.addFilter(filter, type)
		success 'Your filter has been added.'
	end
	
	def commandAddNameFilter
		commandAddFilter('name')
	end
	
	def commandAddNFOFilter
		commandAddFilter('nfo')
	end
	
	def commandAddGenreFilter
		commandAddFilter('genre')
	end
	
	def commandListFilters
		filterTypeDescriptions =
		{
			'name' => nil,
			'nfo' => [:lightGreen, 'NFO filter'],
			'genre' => [:pink, 'MP3 genre filter'],
		}
		filters = @api.listFilters
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
		
		indices = convertFilterIndexStrings(@arguments)
		return if indices == nil
		@api.deleteFilters(indices)
		
		if indices.size == 1
			puts 'The filter has been removed.'
		else
			puts 'The filters have been removed.'
		end
	end
	
	def commandClearFilters
		@api.clearFilters
		puts 'All your filters have been removed.'
	end
	
	def commandDatabase
		timer = Timer.new
		queryCount = 0
		@sites.each do |site|
			statistics = @api.getSiteStatistics(site)
			
			data =
			[
				['Number of releases in the database', statistics.releaseCount.to_s],
				['Size of releases available on demand', Nil.getSizeString(statistics.totalSize)],
			]
			
			puts "#{stringColour(site.name)}:"
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
	
		timer = Timer.new
		
		siteResults = @api.search(@argument)
		count = 0
		siteResults.each do |siteName, results|
			count += results.size
		end
		
		delay = timer.stop
		
		if count == 0
			warning 'Your search yielded no results.'
			return
		end
		
		searchResults = {}
		@sites.each do |site|
			results = siteResults[site.name]
			results.each do |result|
				name = result.name
				if searchResults[name] == nil
					searchResults[name] = result
				else
					searchResults[name].processData(site, result.id, result.date)
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
		
		success = downloadTorrentByName(target)
		if success
			success 'Success!'
		else
			error "Unable to find release \"#{target}\"."
		end
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
		result = downloadTorrentFromSite(site, id)
		if result == false
			error 'You have specified an invalid ID.'
			return
		end
		
		success 'Success!'
	end
	
	def commandStatus
		puts 'Status of the server:'
		
		freeSpace = Nil.getSizeString(@api.getFreeSpace)
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
		if @arguments.empty?
			warning 'You need to specify a release which you would like to have removed. (cancels download/upload)'
			return
		end
		target = @argument
		@api.deleteTorrent(target)
		success "#{target} has been removed successfully."
	end
	
	def commandExit
		puts Nil.lightGreen('See you.')
		#sleep 1
		exit
	end

	def commandPermissions
		if @api.isAdministrator
			userLevel = 'Administrator'
		else
			userLevel = 'Regular user'
		end
		
		sizeLimitString = Nil.getSizeString(@api.getReleaseSizeLimit)
		
		data =
		[
			['User level', userLevel],
			['Size limit per release', sizeLimitString],
			['Search result limit per site', @api.getSearchResultCountMaximum.to_s],
		]
		
		printData data
	end
	
	def commandSSH
		if @arguments.size < 2 || @arguments.index("\n") != nil
			error "Your SSH data does not fit the following pattern: ssh-(rsa|dsa) data [comment]"
			return
		end
		if @argument.size >= @sshKeyMaximum
			error "Your SSH data exceeds the maximal length of #{@sshKeyMaximum}."
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
			error 'Unable to create the directory - please contact the administrator'
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
		indexStrings = @arguments[1..-1]
		
		indices = convertFilterIndexStrings(indexStrings)
		if indices.index(nil) != nil
			error 'You have specified an invalid filter index.'
			return
		end
		@api.assignCategoryToFilters(category, indices)
		
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
		@api.deleteCategory(category)
		success "Removed category \"#{category}\""
	end
end
