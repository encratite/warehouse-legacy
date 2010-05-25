require 'user-api/SearchResult'

class UserAPI
	def search(target)
		if target.size > @filterLengthMaximum
			error "Your search filter exceeds the maximum length of #{@filterLengthMaximum}."
			return
		end
		
		siteResults = {}
		@sites.each do |site|
			table = site.table.to_s
			key = site.name
			results = @database["select site_id, section_name, name, release_date, release_size from #{table} where name ~* ? order by site_id desc limit ?", target, @searchResultMaximum].all
			siteResults[key] = results.map do |result|
				SearchResult.new(site, result)
			end
		end
		
		return siteResults
	end
end
