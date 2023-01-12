#!/usr/bin/ruby

require 'json'

@bugCount = 0
@issueCount = 0

IO.foreach("OPENJPA_issueID_and_type.json") do |line|
    if (line =~ /OPENJPA/)
      @issueCount += 1 
    end
    if ((line =~ /OPENJPA/) && (line =~ /Bug/))
      @bugCount += 1
    end
end

@percentage_of_issue_that_are_bugs = (@bugCount.to_f / @issueCount) * 100
puts "Issues = #@issueCount"
puts "Bugs = #@bugCount"
puts "Percentage of issues that are bugs: #@percentage_of_issue_that_are_bugs %"
