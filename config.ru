require 'faye'
require 'sinatra'

set :port, 9292
set :faye_client, Faye::Client.new('http://localhost:9292/faye')

get '/' do
  send_file 'public/client.html'
end

Faye::WebSocket.load_adapter 'thin'

use Faye::RackAdapter, mount: '/faye', timeout: 45, extensions: [] do |bayeux|
  bayeux.on(:subscribe) do |client_id, channel|
    if channel == '/status'
#      bayeux.get_client.publish('/status', {
#        'data' => [1, 2, 3, 4]
#      })
    end
  end
end

run Sinatra::Application
