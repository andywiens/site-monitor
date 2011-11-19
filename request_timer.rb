require 'net/http'
require 'net/https'
require 'data_mapper'

class Result
  include DataMapper::Resource
  property :id, Serial
  property :start_time, DateTime
  property :duration, Float
  property :code, Integer
end


BREAK_IN_SECONDS = 30
HOST = 'registry.nic.fm'
PATH = '/login.jsp'
OPTS = {:use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE}

def timeit
  start = Time.now
  yield
  [start, Time.now - start]
end

def db_file
  "sqlite://#{File.expand_path( File.dirname(__FILE__) )}/db/request_timer.db"
end

def setup
  puts "Using db file: #{db_file}"
  DataMapper.setup(:default, db_file)
  DataMapper.finalize
  DataMapper.auto_upgrade!
end

def measure_once
  resp = nil
  length = timeit do  

    resp = Net::HTTP.start(HOST,443,nil,nil,nil,nil,OPTS) do |conn|
      conn.get2(PATH)
    end

  end
  
  Result.create(
    :start_time => length[0],
    :duration => length[1],
    :code => resp.code 
  )
end

setup

while true
  measure_once
  sleep BREAK_IN_SECONDS
end