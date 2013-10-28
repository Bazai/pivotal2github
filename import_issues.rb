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


def add_pt_label(labels, text)
  result = labels
  if result != ''
    result += ','
  end
  result += text
  return result
end


filename = ARGV.shift or raise "Enter Filepath to CSV as ARG1"

class GitHub
  include HTTParty
  base_uri 'https://api.github.com'

end
user = get_input("Enter Username >")
password = get_input("Enter Password >", "*")
GitHub.basic_auth user, password

repository_path = get_input("Enter Repository Path (e.g. user/repository-name) >")
raise "Repository should contain a forward slash ('/')" unless repository_path =~ /\w\/\w/

visited_labels = []
CSV.open filename, :headers => true do |csv|
  csv.each do |r|
    body = {
      :title => r['Story'],
      :body => r['Description'],
    }
    labels = []


    # Give PT Bugs the GitHub "bug" label.
    if r['Story Type'] == 'bug'
      r['Labels'] = add_pt_label(r['Labels'], 'bug')
    end

    # Give PT Icebox stories the "PT-icebox" GitHub label.
    if r['Current State'] == 'unscheduled'
      r['Labels'] = add_pt_label(r['Labels'], 'PT-icebox')
    end

    # Give completed PT stories the "PT-accepted" GitHub label.
    # GitHub's Issues API doesn't allow the creation of closed
    # issues:
    # http://developer.github.com/v3/issues/#create-an-issue
    # So this label enables the user to convert the accepted
    # items to the GitHub closed status.
    # TODO: Use the Issue/edit API to change status to closed.
    #
    # If this isn't desired, then simply don't export done
    # stories from Pivotal Tracker.
    if r['Current State'] == 'accepted'
      r['Labels'] = add_pt_label(r['Labels'], 'PT-accepted')
    end


    if r['Labels'] != ''
      r['Labels'].split(',').each do |label|
        label = label.strip
        color ='' 
        3.times { 
          color << "%02x" % rand(255)
        }
       unless visited_labels.include? label
        labels << {:name => label, :color =>color} 
       end
      end
      labels.each do |label|
        # p label
        # this hack doesn't care if you have an existing label - it just errors and moves on like a zen master
        # the server however is expected to be equally zen :D
        visited_labels << label[:name]
        label = GitHub.post "/repos/#{repository_path}/labels", :body => JSON.generate(label)
        # p label
      end
    end
    
    body[:labels] = r['Labels'].split(',').map {|l|l.strip} if r['Labels'] != ''

   
    p body[:title]
    json_body = JSON.generate(body)
    issue = GitHub.post "/repos/#{repository_path}/issues", :body => json_body
    # p issue

    r.each do |f|
      if f[0] == 'Note'
        next unless f[1]
        body = { :body => f[1] }
        GitHub.post "/repos/#{repository_path}/#{issue.parsed_response['number']}/comments", :body => JSON.generate(body)
      end
    end
  end
end
