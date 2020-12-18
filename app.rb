require 'rubygems'
require 'bundler'
Bundler.require(:app)

class App < Sinatra::Base

  post('/ping/?') do
    Thread.new{ system('./bin/build') }
    content_type 'text/plain'
    '202 Accepted'
  end

  get('/?') do
    content_type 'text/plain'
    '200 OK'
  end

  not_found do
    halt 404, {'Content-Type' => 'text/plain'}, '404 Not Found'
  end
end
