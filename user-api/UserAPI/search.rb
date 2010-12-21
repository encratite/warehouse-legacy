require 'user-api/SearchResult'

class UserAPI
  def search(target, isRegex)
    begin
      if target.size > @filterLengthMaximum
        error "Your search filter exceeds the maximum length of #{@filterLengthMaximum}."
        return
      end

      siteResults = {}
      @sites.each do |site|
        table = site.table.to_s
        key = site.name
        operator = isRegex ? '~*' : 'ilike'
        results = @database["select site_id, section_name, name, release_date, release_size, seeder_count from #{table} where name #{operator} ? order by site_id desc limit ?", target, @searchResultMaximum].all
        siteResults[key] = results.map do |result|
          SearchResult.new(site, result)
        end
      end

      return siteResults
    rescue Sequel::DatabaseError
      #it might be wise to check the error message of the database error, actually
      raise 'Invalid regular expression'
    end
  end
end
