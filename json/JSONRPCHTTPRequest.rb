require 'json'
require 'cgi'

require 'www-library/HTTPRequest'

class JSONRPCHTTPRequest < HTTPRequest
	attr_reader :jsonInput, :commonName, :name, :serial, :isMultiCall
		
	SubjectData =
	{
		'name' => :@name,
		'CN' => :@commonName,
	}
	
	def initialize(environment)
		super(environment)
		
		@jsonInput = JSON.parse(@rawInput)
		
		subject = environment['HTTP_SSL_SUBJECT']
		parseSubject(subject)
		@serial = environment['HTTP_SSL_SERIAL']
		if @serial == nil
			raise 'Certificate serial number missing in HTTP query'
		end
	end
	
	def parseSubject(subject)
		if subject == nil
			raise 'Certificate subject missing in HTTP query'
		end
		tokens = subject.split('/')[1..-1]
		if tokens.size != SubjectData.size
			raise "Invalid token count in subject: #{subject}"
		end
		data = {}
		tokens.each do |token|
			units = token.split('=')
			if tokens.size != 2
				raise "Invalid token size in subject unit: #{token}"
			end
			key, value = units
			data[key] = value
		end
		SubjectData.each do |key, symbol|
			value = data[key]
			if value == nil
				raise "Missing unit in subject: #{key}"
			end
			instance_variable_set(symbol, value)
		end
	end
end
