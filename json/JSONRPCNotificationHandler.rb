require 'json/JSONRPCHandler'
require 'json/JSONRPCNotificationAPI'

class JSONRPCNotificationHandler < JSONRPCHandler
  def initialize(configuration, connections, outputHandler)
    super(configuration, connections, outputHandler, JSONRPCNotificationAPI)
  end

  def processRPCRequests(client, requests)
    jsonAPI = JSONRPCNotificationAPI.new(@configuration, @connections, client)
    return processRPCRequestsByAPI(client.user, requests, jsonAPI)
  end
end
