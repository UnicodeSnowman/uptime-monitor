require 'eventmachine'
require 'em-hiredis'
require 'faye'
require 'json'

MAX = (60 / 10) * 10 # (60 s/min) / (10 seconds) * (10 minutes) = 60 samples

module Dispatch
  def self.is_overloaded(data = [], size = 12)
    if data.size >= size
      # sum last `size` entries
      load_sum = data[-size..data.size].inject(0) do |sum, v|
        sum + v["minute_intervals"]["one"].to_f
      end
      avg_load = load_sum / size
      avg_load > 1
    else
      false
    end
  end

  def self.run
    EM.run {
      client = Faye::Client.new('http://localhost:9292/faye')
      redis = EM::Hiredis.connect('http://localhost:6666')

      client.subscribe('/update') do |message|
        current_status = message["status"]

        # trim to one less than MAX so that the most recent entry can be appended
        redis.ltrim('DS', 0, MAX - 1)

        redis.lrange('DS', 0, -1).callback do |msgs|
          ordered_messages = msgs.reverse.map { |msg| JSON.parse(msg) }
          ordered_messages.push(current_status)

          # check last two minutes, avg load
          if ordered_messages.size >= 12 && is_overloaded(ordered_messages)
            ordered_messages.last["alert"] = true
          end

          redis.lpush('DS', current_status.to_json)
          client.publish('/status', ordered_messages.to_json)
        end
      end
    }
  end
end

