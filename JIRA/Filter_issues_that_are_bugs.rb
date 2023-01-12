#!/usr/bin/ruby

require 'json'

File.open('OPENJPA_Bugs.json', 'a') do |output|
  IO.foreach("OPENJPA_issueID_and_type.json") do |line|
    if ((line =~ /OPENJPA/) && (line =~ /Bug/))
      output.write(line)
    end
  end
end


