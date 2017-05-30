#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'date'
require 'yaml'
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
        sha: client.create_blob(repo, new_content)
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

commit(client, repo, ref, 'new-branch', 'This is a test', {"foo.md" => "Foo!"})

