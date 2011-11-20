$: << File.dirname(__FILE__)

require 'net/http'
require 'net/https'
require 'request_db'
require 'charts'

module SiteMonitor
  extend self

  BREAK_IN_SECONDS = 30
  HOST = 'registry.nic.fm'
  PATH = '/login.jsp'
  OPTS = {:use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE}

  def timeit
    start = Time.now
    yield
    [start, Time.now - start]
  end

  def measure_once
    resp = nil
    length = timeit do  

      resp = Net::HTTP.start(HOST,443,nil,nil,nil,nil,OPTS) do |conn|
        conn.get2(PATH)
      end

    end

    DB::Result.create(
    :start_time => length[0],
    :duration => length[1],
    :code => resp.code 
    )
  end

  def results_to_data_array results
    index = 0
    results.collect do |single|
      index += 1
      {:x => index, :y => single.duration * 1000}
    end
  end

  def monitor_site
    while true
      measure_once
      sleep BREAK_IN_SECONDS
    end
  end

  def chart_history
    Chart.chart(
    results_to_data_array(DB::Result.all),
    'history.png'
    )
  end

  DB.setup

end

case ARGV.shift
when 'm'
  SiteMonitor.monitor_site
when 'h'
  SiteMonitor.chart_history
else
end

