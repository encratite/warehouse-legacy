#this script is necessary to fix old invalid notification content data which still features date strings instead of UNIX timestamps
#(which is invalid according to the protocol specs)

$: << '.'

require 'time'

require 'shared/ConnectionContainer'
require 'json/parse'

connections = ConnectionContainer.new
database = connections.sqlDatabase
notifications = database[:user_notification]
rows = notifications.select(:id, :notification_type, :content)
puts rows.sql
rows.each do |row|
	id = row[:id]
	type = row[:notification_type]
	content = parseJSON(row[:content])
	case type
	when 'downloadError'
		path = ['release', 'time']
	when 'queued', 'downloaded', 'downloadDeleted'
		path = ['time']
	else
		next
	end
	time = content
	path.each do |x|
		time = content[x]
	end
	
	next if time.class != String
	
	time = Time.parse(time).to_i
	
	container = content
	path[0..-2].each do |x|
		container = content[x]
	end
	
	container[path[-1]] = time
	
	content = content.to_json
	notifications.where(id: id).update(content: content)
end
