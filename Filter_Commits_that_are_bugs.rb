#!/usr/bin/ruby


File.open('openjpa/Bugs_log.txt', 'a') do |output|
  IO.foreach("openjpa/log_Vitals.txt") do |line1|
    if (line1 =~ /OPENJPA-.*\d/)
      @temp = line1.match(/OPENJPA-.*\d/)
      #@start = line1.index(/OPENJPA-.*\d/)
      #@temp = line1[(@start)..(@start+9)]
      IO.foreach("OpenJPA-JIRA/json/OPENJPA_Bugs.json") do |line2|
        if (line2 =~ /#@temp\s/)
          output.write(line1)
        end
      end
    end
  end
end

