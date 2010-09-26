require 'nil/console'
require 'nil/string'

require 'shell/stringColour'

require_relative 'json/JSONObject'

class SearchResult < JSONObject
	attr_reader :id, :name, :date
	
	def initialize(site, data)
		#do not serialise the descriptions
		super([:@descriptions])
		@name = data[:name]
		@section = data[:section_name]
		@size = data[:release_size]
		@date = data[:release_date].utc
		#warning - this data is pretty useless and outdated - can help on old torrents though I suppose
		@seederCount = data[:seeder_count]
		@descriptions = []
		@id = data[:site_id]
		processData(site, @id, @date)
	end
	
	def processData(site, id, releaseDate)
		@date = releaseDate.utc if @date == nil
		source = stringColour(site.abbreviation)
		description = "#{source}: #{id}"
		@descriptions << description
	end
	
	def getString
		section = stringColour @section
		date =
			@date == nil ?
			'' :
			", #{@date.utc.to_s}"
		descriptions = @descriptions.join(', ')
		output = "[#{section}] #{@name} [#{Nil.white(Nil.getSizeString(@size))}#{date}] [#{descriptions}]"
		return output
	end
end
