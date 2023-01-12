#!/usr/bin/ruby

@commitCount = 0
@issueCount = 0

 
IO.foreach("openjpa/log_Vitals.txt") do |line|
    if (line =~ /Commit/)
      @commitCount += 1 
    end
    if ((line =~ /Commit/) && (line =~ /OPENJPA/))
      @issueCount += 1
    end
end

@percentage_of_commits_that_are_Jira_issues = (@issueCount.to_f / @commitCount) * 100
puts "Commits = #@commitCount"
puts "Issues = #@issueCount"
puts "Percentage of commits that are Jira issues: #@percentage_of_commits_that_are_Jira_issues %"




