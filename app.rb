require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

# Logs to terminal, I use this to peek into Tweetbot requests.
# Use `puts` inside any action to log to terminal.
#
require 'logger'
class ::Logger; alias_method :write, :<<; end
$stdout.sync = true

class App < Sinatra::Base

  get('/ping/?') do
    Thread.new{ system('./bin/build') }
    "OK"
  end

  get('/?') do
    not_found
  end

private

  def not_found
    halt(404, 'Not Found')
  end
end