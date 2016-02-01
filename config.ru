require 'sinatra'
require './app.rb'

#run Footy

Footy.run!  :port => 4567, :bind => '0.0.0.0'