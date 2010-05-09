require 'zlib'
require 'nil/console'
require 'nil/environment'

def stringColour(input)
	return input if Nil.getOS == :windows
	
	colours =
	[
		:LightRed,
		:LightBlue,
		:LightGreen,
		:LightCyan,
		:Red,
		:Green,
		:Cyan,
		:Yellow,
		:Pink
	]
	
	hash = Zlib.crc32(input)
	colour = Nil::Console.const_get(colours[hash % colours.size])
	return colour + input + Nil::Console::Normal
end
