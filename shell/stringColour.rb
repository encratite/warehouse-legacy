require 'zlib'
require 'nil/console'

def stringColour(input)
	include Nil.Console
	
	Colours =
	[
		LightRed,
		LightBlue,
		LightGreen,
		LightCyan,
		Red,
		Green,
		Cyan,
		Yellow,
		Pink
	]
	
	hash = Zlib.crc32(input)
	colour = Colours[hash % Colours.size]
	return colour + input + Normal
end
