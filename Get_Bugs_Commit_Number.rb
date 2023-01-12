#!/usr/bin/ruby

File.open('openjpa/Bugs_Commit_Numbers.txt', 'a') do |output|
  IO.foreach("openjpa/Bugs_log.txt") do |line1|
    @commit_Number = line1[0..47]
    output.puts(@commit_Number)
  end
end
