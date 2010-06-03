def extractCertificateName(subject)
	tokens = subject.to_s.split('/')
	dictionary = {}
	tokens.each do |token|
		innerTokens = token.split('=')
		next if innerTokens.size != 2
		key, value = innerTokens
		dictionary[key] = value
	end
	name = dictionary['name']
	raise 'Certificate subject contains no name' if name == nil
	return name
end
