require 'data_mapper'

module SiteMonitor
  module DB extend self

    class Result
      include DataMapper::Resource
      
      storage_names[:default] = 'results'
      
      property :id, Serial
      property :start_time, DateTime
      property :duration, Float
      property :code, Integer
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

  end
end
