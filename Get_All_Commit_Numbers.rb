#!/usr/bin/ruby

File.open('openjpa/All_Commit_Numbers.txt', 'a') do |output|
  IO.foreach("openjpa/log_Vitals.txt") do |line1|
    @commit_Number = line1[0..47]
    output.puts(@commit_Number)
  end
end

