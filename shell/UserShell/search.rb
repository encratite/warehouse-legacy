class UserShell
  def performSearch(target, useRegex)
    if target.empty?
      warning "Specify a pattern to look for."
      return
    end

    timer = Timer.new

    siteResults = @api.search(target, useRegex)
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
end
