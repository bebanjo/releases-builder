#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'date'
require 'yaml'
require 'open-uri'
require 'base64'
Bundler.require
Dotenv.load

def parse_date(str)
  begin
    DateTime.parse(str).strftime('%Y-%m-%d')
  rescue
    raise 'Invalid date'
  end
end

def get_filename(body)
  begin
    frontmatter = YAML.load(body)
    title       = frontmatter['title'].to_slug.normalize.to_s
    date        = parse_date(frontmatter['date'].to_s)
    filename    = "#{date}-#{title}"
    filename
  rescue
    raise 'Invalid frontmatter'
  end
end

# https://github.com/jollygoodcode/jollygoodcode.github.io/issues/14
def commit(client, repo, ref, branch, message, content)
  begin
    base_branch = client.refs(repo).find do |reference|
      "refs/heads/#{ref}" == reference.ref
    end
    
    base_branch_sha = base_branch.object.sha
    new_branch = client.create_ref(repo, "heads/#{branch}", base_branch_sha)
    
    new_tree = content.map do |path, new_content|
      Hash(
        path: path,
        mode: '100644',
        type: 'blob',
        sha: client.create_blob(repo, new_content, 'base64')
      )
    end
    
    commit = client.git_commit(repo, new_branch['object']['sha'])
    tree = commit['tree']
    new_tree = client.create_tree(repo, new_tree, base_tree: tree['sha'])
    new_commit = client.create_commit(repo, message, new_tree['sha'], commit['sha'])
    
    client.update_ref(repo, "heads/#{branch}", new_commit['sha'])
  rescue
    raise 'Commit failed'
  end
end

def pr(client, repo, ref, branch, title, body)
  client.create_pull_request(repo, ref, branch, title, body)
end

token = ENV['TOKEN']
repo  = ENV['REPO']
ref   = ENV['REF']

client = Octokit::Client.new(:access_token => token)
Octokit.auto_paginate = true

# Get all issues that comply
# issues = client.list_issues(repo)
# releases = issues.map do |issue|
#   issue if issue[:body].to_s.split("\n").first.include?('---')
# end.compact

# Check for reactions
# releases.each do |release|
#   reactions = client.issue_reactions(repo, release[:number])
#
#   counts = Hash.new(0)
#   reactions.each do |reaction|
#     counts[reaction[:content]] += 1
#   end
#
#   if counts['+1'] == 1
#     puts get_filename(release[:body])
#   end
# end

def prepare_content(body)
  content = Hash.new

  name = get_filename(body)
  updated_body = body

  regex = /[\"|\(](https:\/\/cloud.githubusercontent.com\/.*)[\"|\)]/
  attachments = body.scan(regex).uniq

  attachments.each_with_index do |attachment, i|
    extension = attachment[0].split('.').last
    file = open(attachment[0]) { |f| f.read }
    blob = Base64.encode64(file)
    index = "%02d" % (i + 1)
    filename = "media/#{name}-#{index}.#{extension}"
    content[filename] = blob
    
    updated_body.gsub!(attachment[0], "../#{filename}")
  end
  
  content["_posts/#{name}.md"] = Base64.encode64(updated_body)
  
  content
end

file = File.open("test.md", "rb")
body = file.read
content = prepare_content(body)

commit(client, repo, ref, 'new-branch', 'This is the message', content)

# Commit changes to the branch
# commit(client, repo, ref, 'new-branch', 'This is the message', {"foo.md" => "Foo!"})

# Create the pull request
# pr(client, repo, ref, 'new-branch', 'This is the title', 'This is the body')
