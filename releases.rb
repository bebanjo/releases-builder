#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'uri'
require 'fileutils'
require 'json'
Bundler.require
Dotenv.load

Octokit.auto_paginate = true

repo   = ENV['REPO']
client = Octokit::Client.new(:access_token => ENV['TOKEN'])
issues = client.list_issues(repo)

# issues[0][:title]
# issues[0][:body]

# releases = Array.new
# issues.each do |issue|
#   if issue[:title].include?('Release note:') or
#      issue[:title].include?('Release Note:') or
#      issue[:title].include?('Release note for')
#     releases << issue[:title]
#   end
# end

releases = issues.map do |issue|
  issue if issue[:title].downcase.include?('release note:')
end.compact

releases.each do |release|
  puts release[:number]
end


# client.issue_reactions(repo, 106).each do |reaction|
#   puts reaction[:content]
# end
