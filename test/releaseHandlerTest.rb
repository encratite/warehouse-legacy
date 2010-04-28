require 'nil/file'
require '../manager/ReleaseData'

def processFile(path)
	input = Nil.readFile(path)
	data = ReleaseData.new(input)
end

begin
	[
		'data/input.html',
		'data/input2.html'
	].each do |path|
		processFile(path)
	end
rescue Exception => exception
	puts "Exception: #{exception.message}"
end
