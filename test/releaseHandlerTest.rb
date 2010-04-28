require 'nil/file'
require '../ReleaseData'

input = Nil.readFile('data/input.html')
begin
	data = ReleaseData.new(input)
rescue Exception => exception
	puts "Exception: #{exception.message}"
end
