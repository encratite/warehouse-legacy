require 'nil/file'
require 'shared/SceneAccessReleaseData'

def processFile(path)
	input = Nil.readFile(path)
	data = SceneAccessReleaseData.new(input)
end

begin
	[
		'data/input.html',
		'data/input2.html',
		'data/input3.html',
	].each do |path|
		processFile(path)
	end
rescue Exception => exception
	puts "Exception: #{exception.message}"
end
