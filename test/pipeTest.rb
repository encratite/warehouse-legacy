IO.popen('cat', mode = 'r+') do |io|
  io.write 'test'
  io.close_write
  data = io.read
  puts "Output: #{data}"
end
puts "Exit code: #{$?.to_i}"
