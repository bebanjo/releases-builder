require 'rubygems'
require 'bundler'
Bundler.require(:app)

class App < Sinatra::Base

  post('/ping/?') do
    Thread.new{ system('./bin/build') }
    '202 Accepted'
  end

  get('/?') do
    '200 OK'
  end

  not_found do
    halt(404, '404 Not Found')
  end
end
