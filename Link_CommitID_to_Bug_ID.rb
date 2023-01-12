#!/usr/bin/ruby


File.open('openjpa/Linking_Commit_to_Bug.txt', 'a') do |output|
  IO.foreach("openjpa/log_Vitals.txt") do |line1|
    if (line1 =~ /OPENJPA-.*\d/)
      @temp = line1.match(/OPENJPA-.*\d/)
      #@start = line1.index(/AMQ-.*\d/)
      #@temp = line1[(@start)..(@start+9)]
      IO.foreach("OpenJPA-JIRA/json/OPENJPA_Bugs.json") do |line2|
        if (line2 =~ /#@temp\s/)
          commitID = line1[0..47]
          output.puts"#{commitID}, #{@temp}"     
        end
      end
    end
  end
end

