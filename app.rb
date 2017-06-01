require 'rubygems'
require 'bundler'
Bundler.require(:app)

class App < Sinatra::Base

  post('/ping/?') do
    Thread.new{ system('./bin/build') }
    "OK"
  end

  get('/?') do
    not_found
  end

private

  def not_found
    halt(404, '404')
  end
end
