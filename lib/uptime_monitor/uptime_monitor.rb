require 'eventmachine'
require 'faye'

INTERVAL = 10 # seconds

module UptimeMonitor
  def self.check_uptime
    system_info = `uptime`

    # TODO clean this up/improve regex in case `uptime` format on different systems is *slightly* different
    time, days_up, one, five, fifteen = system_info.match(/(\d+:\d+)\W+up (\d+) days.*load averages: (\d+\.\d+) (\d+\.\d+) (\d+\.\d+)/).captures
    status = {
      time: time,
      days_up: days_up,
      alert: false,
      minute_intervals: {
        one: one,
        five: five,
        fifteen: fifteen
      }
    }
    status
  end

  def self.run
    EM.run {
      client = Faye::Client.new('http://localhost:9292/faye')

      EventMachine::PeriodicTimer.new(INTERVAL) do
        publication = client.publish('/update', status: check_uptime)

        publication.errback do |error|
          puts 'there was a problem: ' + error.message
        end
      end
    }
  end
end

