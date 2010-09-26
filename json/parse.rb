require 'json'

#this function is required due to the changes in the JSON library from 1.9.1 to 1.9.2
#it is no longer capable of parsing stuff like "test" or 1 - everything needs to be inside [] or {}
#so we're going to cheat our way out of this by turning the input into an array - hah!
def parseJSON(input)
	return JSON.parse("[#{input}]")[0]
end
