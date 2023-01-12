#!/usr/bin/ruby

require 'json'

File.open('OPENJPA_Bugs_dates.json', 'a') do |output|
  IO.foreach("OPENJPA_issueID_created.json") do |line|
    if ((line =~ /OPENJPA/) && (line =~ /Bug/))
      line.to_str.sub!("T", "\s")
      @temp = /^(.*)(?=\.)/.match(line)
      output.puts @temp
    end
  end
end


