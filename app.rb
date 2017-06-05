require 'rubygems'
require 'bundler'
Bundler.require(:app)

class App < Sinatra::Base

  post('/ping/?') do
    Thread.new{ system('./bin/build') }
    '202 Accepted'
  end

  get('/?') do
    halt(404, '200 OK')
  end
end