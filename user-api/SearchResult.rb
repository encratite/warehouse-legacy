require 'nil/console'

require 'shell/stringColour'

require 'user-api/JSONObject'

class SearchResult < JSONObject
	attr_reader :id
	
	def initialize(source, data)
		#do not serialise the descriptions
		super(:@descriptions)
		@name = data[:name]
		@section = data[:section_name]
		@size = data[:release_size]
		@date = data[:release_date]
		@descriptions = []
		@id = data[:site_id]
		processData(source, data)
	end
	
	def processData(source, data)
		@date = data[:release_date] if @date == nil
		source = stringColour source
		description = "#{source}: #{data[:site_id]}"
		@descriptions << description
	end
	
	def getString
		section = stringColour @section
		date =
			@date == nil ?
			'' :
			", #{@date.utc.to_s}"
		descriptions = @descriptions.join(', ')
		output = "[#{section}] #{@name} [#{Nil.white @size}#{date}] [#{descriptions}]"
		return output
	end
end
