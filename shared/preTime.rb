def parsePreTimeString(input)
	preTimePatterns =
	[
		[/(\d+) sec/, 1],
		[/(\d+) min/, 60],
		[/(\d+) hour/, 60],
		[/(\d+) day/, 24],
		[/(\d+) week/, 7]
	]
	
	factor = 1
	preTime = 0
	preTimePatterns.each do |pattern, currentFactor|
		factor *= currentFactor
		match = pattern.match(input)
		break if match == nil
		data = match[1]
		preTime += data.to_i * factor
	end
	
	if preTime == 0
		return nil
	else
		return preTime
	end
end
