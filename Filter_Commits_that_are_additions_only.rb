#!/usr/bin/ruby

#require "pry"

#Need to recreate Bugs_Commit_Numbers.txt before running this



file_content = File.read("openjpa/log.txt")

commits_array = []
file_content.split("\nCommit").each_with_index do |commit, index|
  if index.zero?
    commits_array << commit.chomp
  else
    commits_array << ("Commit" + commit).chomp
  end
end

insertions_commit = commits_array.select do |commit|
  commit =~ /insertions?\(\+\)\z/
end


commit_numbers = insertions_commit.map do |commit|
  commit.split(",").first
end
puts commit_numbers

commit_logs = File.readlines("openjpa/Bugs_Commit_Numbers.txt").map(&:chomp)


commit_total_number = commit_logs.count

needed_commit = []

commit_numbers.each do |commit|
  commit_logs.each do |log|
    needed_commit << commit if log == commit
  end
end

puts needed_commit.count.to_f/commit_total_number * 100

#needed_commit contains the commit numbers of bug-fixing commits that are addition only
#Write those to a file
File.open("openjpa/Add_only_BFC_numbers.txt", "w+") do |f|
  f.puts(needed_commit)
end

Not_add_only_BFC_numbers = []
#Create a file with the commit numbers of bug-fixing commits that are not addition only
for com in commit_logs
  if !needed_commit.include? com
    Not_add_only_BFC_numbers << com
  end
end

File.open("openjpa/Not_add_only_BFC_numbers.txt", "w+") do |f|
  f.puts(Not_add_only_BFC_numbers)
end

#Need to remove Commit: from each line in Not_add_only_BFC_numbers.txt and after running this


