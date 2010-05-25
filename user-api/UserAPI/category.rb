require 'nil/file'
require 'fileutils'

class UserAPI
	def assignCategoryToFilters(category, indices)
		if isIllegalName(category)
			error 'You have specified an invalid folder.'
		end
		
		@database.transaction do		
			ids = convertFilterIndices(indices)
			ids.each do |id|
				@filters.where(id: id).update(category: category)
			end
		end
	end
	
	def deleteCategory(category)
		if isIllegalName(category)
			error 'You have specified an invalid path.'
		end
		
		path = Nil.joinPaths(@filteredPath, category)
		begin
			FileUtils.rm_r(path)
		rescue Errno::ENOENT
			error "Unable to find category \"#{category}\" in your folder."
		end
	end
end
