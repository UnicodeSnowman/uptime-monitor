require 'eventmachine'
require 'faye'

# ideally should use something else for data store... redis?
DS = []
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

      client.subscribe('/update') do |message|
        DS.shift if DS.size >= MAX

        current_status = message["status"]

        # check last two minutes, avg load
        if DS.size >= 12 && is_overloaded(DS)
          current_status["alert"] = true
        end

        DS << current_status

        # send message off to browser client
        client.publish('/status', DS)
      end
    }
  end
end

