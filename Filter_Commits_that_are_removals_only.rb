#!/usr/bin/ruby

#require "pry"

file_content = File.read("openjpa/log.txt")

commits_array = []
file_content.split("\nCommit").each_with_index do |commit, index|
  if index.zero?
    commits_array << commit.chomp
  else
    commits_array << ("Commit" + commit).chomp
  end
end

removals_commit = commits_array.select do |commit|
  (!(commit =~ /insertions?\(\+\)/) && (commit =~ /deletions?/))
end

puts removals_commit

removals_amount = removals_commit.length
commits_total_amount = commits_array.count

puts removals_amount.to_f/commits_total_amount * 100



