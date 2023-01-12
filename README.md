## Ghost Commits Analysis

This contains a description of the scripts used to mine git repositories in order to quantify and characterize three different types of "Ghost Commits": __MG 1__, __MG 2__, and __FG__.

A zip file containing a sample cloned repository, as well as sample outputs of the scripts below, can be found in the Sample Data zip file. 

## Usage
Clone the git repository of a project and navigate to it.

Use the following git commands to download all commits into a __.txt__ file:
```
git config diff.renameLimit 999999 
git --no-pager log --pretty="Commit: %H, AN: %an, AD: %ad, CN: %cn, CD: %cd, %f" --date=short --stat > log.txt
```
Run _Iterate_and_download_JSON_for_each_issue.rb_ to download all JIRA issues for that project. This also generates an __Errors.txt__ file with issues that could not be found or caused a connection error.

Run _Generate_issueID_and_type_table.rb_ to output a file containing a table with Issue IDs and types.

Run `git --no-pager log --pretty="Commit: %H, AN: %an, AD: %ad, CN: %cn, CD: %cd, %f" --date=short > log_Vitals.txt` in the cloned repository to generate a __log_Vitals.txt__ file containing required commit metadata.

Run _Get_All_Commit_Numbers.rb_ to create a file containing all commit shas.

Run _Get_Percent_of_commits_that_are_Jira_issues.rb_ to parse the __log_Vitals.txt__ file and output the percentage of commits that are also JIRA issues.

Run _Get_Percent_of_issues_that_are_bugs.rb_ to obtain the percentage of issues that are bugs.

Run _Filter_issues_that_are_bugs.rb_ to create a file containing the Issue IDs of bugs only.

Run _Get_Issue_Dates.rb_ to extract the date each issue was created then run _Get_Bugs_Dates_ to extract the dates of bugs only.

Run _Filter_commits_that_are_bugs.rb_ then _Get_Bugs_Commit_Number.rb_ to parse the __log_Vitals.txt__ file and output the commit shas of bug fixing commits.

Run _Link_CommitID_to_Bug_ID.rb_ to link each Bug ID to one or more commit shas, creating a new file __Linking_Commit_to_Bug.txt__.

Run _Link_CommitID_to_Creation.rb_ to parse the __Linking_Commit_to_Bug.txt__ file and create a new file __Linking_CommitID_to_Bug_Creation.txt__, which contains commmit shas linked to the associated bug-report creation date.

Run _Filter_commits_that_are_additions_only.rb_ to calculate an initial ratio of __MG 1__.

Run _clean_Add_Only_BFC.rb_ in the cloned repository to remove non-code changes and calculate an updated __MG 1__ ratio.

Run _Filter_Commits_that_are_removals_only.rb_ in the cloned repository to calculate an initial ratio of __MG 2__.

Run _Clean_MG2.rb in the cloned repository to remove non-code changes and calculate an updated __MG 2__ ratio. 

Run _filters.rb_ in the cloned repository, which runs the _date_Filter.rb_, _comments_Filter.rb_, _whitespace_filter.rb_, and _size_Filter.rb_ files, and outputs the ratio of FG removed by each step of the SZZ filtering process.
