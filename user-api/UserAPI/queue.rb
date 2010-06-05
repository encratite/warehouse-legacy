require 'sequel'

require 'shared/User'

class UserAPI
	def getQueueEntryUsers(name)
		result = @database[:download_queue].where(name: name).select(:id).all
		return nil if result.empty?
		id = result.first[:id]
		results = @database[:download_queue_user].join(:user_data, :id => :user_id)
		results = results.where(download_queue_user__queue_id: id)
		
		selection =
		[
			:id, :name, :is_administrator, :last_notification
		].map do |x|
			('user_data__' + x.to_s).to_sym.as(x)
		end
		
		results = results.select(*selection)
		users = results.map{|x| User.new(x)}
		return users
	end
end
