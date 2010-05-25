class UserAPI
	def convertFilterIndices(indices)
		ids = []
		
		indices.each do |index|
			if index <= 0
				error "Index too low: #{index}"
			end
			result = @filters.where(user_id: @user.id).order(:id).select(:id).limit(1, index - 1)
			if result.empty?
				error "Invalid index: #{index}"
			end
			ids << result.first[:id]
		end
		
		return ids
	end
	
	#type may be 'name', 'nfo' or 'genre'
	def addFilter(filter, type)
		if filter.size > @filterLengthMaximum
			error "Your filter exceeds the maximum length of #{@filterLengthMaximum}."
		end
		if @filters.where(user_id: @user.id).count > @filterCountMaximum
			error "You have too many filters (#{filterCountMaximum})."
		end
		
		#check if it is a valid regular expression first
		begin
			@database["select 1 where '' ~* ?", filter].all
			@filters.insert(user_id: @user.id, filter: filter, release_filter_type: type)
		rescue Sequel::DatabaseError => exception
			error "DBMS error: #{exception.message.chop}"
		end
	end
	
	def listFilters
		filters = @filters.where(user_id: @user.id).order(:id).select(:filter, :category, :release_filter_type).all
		return filters
	end
	
	def deleteFilters(indices)
		@database.transaction do
			ids = convertFilterIndices(indices)
			ids.each { |id| @filters.where(id: id).delete }
		end
	end
	
	def clearFilters
		@filters.where(user_id: @user.id).delete
	end
end
