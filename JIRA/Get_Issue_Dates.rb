#!/usr/bin/ruby

#require 'rest_client'
require 'json'


lines = File.open("OPENJPA_jira_issues.json").readlines
File.open("OPENJPA_issueID_created.json", "a") do |file|
  file.puts "issueID,issueDate,issueType"
end

(1..8187).step(3).each do |line|
  begin
    x = JSON.load(lines[line])
    issueID = x["key"]
    issueType = x["fields"]["issuetype"]["name"]
    issueDate = x["fields"]["created"]
    File.open("OPENJPA_issueID_created.json", "a") do |file|
      file.puts "#{issueID},#{issueDate},#{issueType}"
    end
  end
end



