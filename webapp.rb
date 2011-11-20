$: << File.dirname(__FILE__)

require 'sinatra'
require 'request_db'

SiteMonitor::DB.setup

helpers do
  
end

#create a display showing interactive charts for the last 3 days, 6 hours at a time
# work backwards from the current time

get '/:back_num' do
  six_hours = 6 * 3600
  @curr_page = params[:back_num].to_i
  now = Time.now - (3600 * 24 * @curr_page)
  
  @charts = []
  6.times do |num|
    c = Chart.new
    c.start_time = now - (num + 1) * six_hours
    c.end_time = now - num * six_hours
    results = SiteMonitor::DB::Result.all(:start_time.gt => c.start_time,
      :start_time.lte => c.end_time)
    
    c.data = results.collect{ |r| r.duration * 1000 }
    @charts << c
  end
  
  erb :graph
end

get '/' do
  call! env.merge("PATH_INFO" => '/0')
end







class Chart
  attr_accessor :start_time, :interval, :data, :end_time

  def initialize
    @interval = 30000 # 30 seconds
  end
  
  def start_time_utc_millis
    (@start_time.to_time.utc.to_f * 1000).truncate
  end
  
  def data_to_js_array
    "[#{@data.join(',')}]"
  end
end