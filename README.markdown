The request times are measured by request\_timer.rb and can be viewer via the webapp (webapp.rb). I start the timer with this:

    ruby request_timer.rb m 2>1 1>timer.out &

The webapp is a sinatra app that can be started with this:

    ruby -r rubygems webapp.rb &

I'm using sqlite to store the data. Can install it with homebrew.

    brew install sqlite

You'll need the following gems:

datamapper
dm-sqlite-adapter
sinatra
technical\_graph
thin (optional, but is better for sinatra)

which can be installed via 

    bundle install

The domain and a few other options can be set via constants in request\_timer.rb. 

You may need to create a db directory
