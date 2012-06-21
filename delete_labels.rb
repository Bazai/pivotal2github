#encoding:UTF-8
#!/usr/bin/env ruby

require 'rubygems'
require 'csv'
require 'httparty'
require 'json'
require 'highline/import'

def get_input(prompt="Enter >",show = true)
  ask(prompt) {|q| q.echo = show}
end

class GitHub
  include HTTParty
  base_uri 'https://api.github.com'

end
user = get_input("Enter Username >")
password = get_input("Enter Password >", "*")
GitHub.basic_auth user, password


labels = GitHub.get '/repos/your_github_username/your_repository_name/labels'
labels.each do |label|
  p GitHub.delete label['url'].split(GitHub.base_uri).last
end