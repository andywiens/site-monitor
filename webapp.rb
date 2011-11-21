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
    c.start_time = now - ((num + 1) * six_hours)
    c.end_time = now - (num * six_hours)
    results = SiteMonitor::DB::Result.all(:start_time.gt => c.start_time,
      :start_time.lte => c.end_time, :order => [:start_time.asc])
    
    c.data_in_results = results
    
    @charts << c
  end
  
  erb :graph
end

get '/' do
  call! env.merge("PATH_INFO" => '/0')
end


class Chart
  attr_accessor :start_time, :interval, :data_in_results, :end_time
  TIME_WINDOW = 15 # in seconds
  
  def initialize
    @interval = 30000 # 30 seconds
  end
  
  def data_points_without_gaps
    time_index = @start_time.to_time
    points = []
    @data_in_results.each do |result|
      while time_index < (result.start_time.to_time + TIME_WINDOW)
        points << 0
        time_index += (@interval / 1000)
      end
      
      points << (result.duration * 1000).truncate
      time_index += (@interval / 1000)
    end
    
    points
  end
  
  def result_to_time_duration_pair_array_strings result
    "[#{(result.start_time.to_time.utc.to_f * 1000).truncate},#{result.duration * 1000}]"
  end
  
  def data_with_time_to_js_array
    "[#{@data_in_results.collect{ |r| result_to_time_duration_pair_array_strings r}.join(',')}]"
  end
  
  def start_time_utc_millis
    (@start_time.to_time.utc.to_f * 1000).truncate
  end
  
  def data_to_js_array
    "[#{data_points_without_gaps.join(',')}]"
  end
end