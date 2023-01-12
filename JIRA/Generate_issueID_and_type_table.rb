#!/usr/bin/ruby

require 'rest_client'
require 'json'


lines = File.open("OPENJPA_jira_issues.json").readlines
File.open("OPENJPA_issueID_and_type.json", "a") do |file|
  file.puts "issueID       issueType"
end

(1..8187).step(3).each do |line|
  begin
    x = JSON.load(lines[line])
    issueID = x["key"]
    issueType = x["fields"]["issuetype"]["name"]
    File.open("OPENJPA_issueID_and_type.json", "a") do |file|
      file.puts "#{issueID}       #{issueType}"
    end
  end
end