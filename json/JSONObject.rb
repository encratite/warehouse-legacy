#this is a superclass for classes whose members can be serialised to a dictionary for JSON RPC return values
class JSONObject
	def initialize(ignored = [])
		#this contains the symbols which are not to be serialised
		@ignored = ignored
		@ignored << :@ignored
	end
	
	def serialise
		output = {}
		instance_variables.each do |symbol|
			next if @ignored.include?(symbol)
			name = symbol.to_s[1..-1]
			value = instance_variable_get(symbol)
			if value.class == Time
				#all dates are transmitted as UNIX timestamps (integers)
				value = value.to_i
			end
			output[name] = value
		end
		return output
	end
end
