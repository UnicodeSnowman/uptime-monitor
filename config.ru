require 'eventmachine'
require 'faye'
require 'sinatra'
require 'em-hiredis'

set :port, 9292
set :faye_client, Faye::Client.new('http://localhost:9292/faye')

get '/' do
  send_file 'public/client.html'
end

Faye::WebSocket.load_adapter 'thin'

use Faye::RackAdapter, mount: '/faye', timeout: 45, extensions: [] do |bayeux|
  bayeux.bind(:subscribe) do |client_id, channel|
    # TODO how to handle sending initial state to client on connection?
    # Hiredis.connect needs to happen in an EM.run loop, but I can't do that here...
    # likely need to separate Sinatra and Faye (i.e. don't use the RackAdapter as middleware)
#      redis = EM::Hiredis.connect('http://localhost:6666')
#      if channel == '/status'
#        redis.lrange('DS', 0, -1).callback do |msgs|
#          ordered_messages = msgs.reverse
#          bayeux.get_client.publish('/status', ordered_messages)
#        end
#      end
  end
end

run Sinatra::Application
