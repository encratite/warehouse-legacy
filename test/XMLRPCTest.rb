require 'xmlrpc/client'

if ARGV.size < 1
  puts 'Missing arguments'
  exit
end

function = ARGV[0]
arguments = ARGV[1..-1].map{|x| eval(x)}

client = XMLRPC::Client.new('127.0.0.1', '/rtorrent', 80)
begin
  apply = [function] + arguments
  output = client.call(*apply)
  puts output.inspect
rescue XMLRPC::FaultException => exception
  puts "Error: #{exception.message}"
  exit
end
