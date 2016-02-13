# require 'sinatra'
require './app.rb'
run Footy


# require './app.rb'
#
# configure do
#   MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')
# end
#
# if ENV['RACK_ENV'] == 'production'
#   run Footy
# else
#   Footy.run!  :port => 4567, :bind => '0.0.0.0'
# end