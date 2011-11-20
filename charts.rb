require 'technical_graph'
require 'pathname'

module SiteMonitor
  module Chart
    extend self

    def chart(data, filename = 'chart.png')
      ensure_path_for_file File.expand_path(filename)
      
      @tg = TechnicalGraph.new(
        {
          :y_axis_fixed_interval => true,
          :y_min => 300,
          :y_max => 700,
          :y_axis_interval => 100,
          :y_axis_label => "time in ms",
          
          :x_axis_fixed_interval => true,
          :x_min => 0,
          :x_axis_interval => 60,
          :x_axis_label => "request",
          
          :truncate_string => "%.0f",
          :height => 800
          
        }
      )
      @tg.add_layer(data)
      @tg.render
      @tg.image_drawer.save_to_file(filename)

    end
    
    def ensure_path_for_file qualified_file
      full = Pathname.new qualified_file
      full.parent.mkpath
    end

  end

end