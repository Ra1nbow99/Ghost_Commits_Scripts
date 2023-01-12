#!/usr/bin/ruby


File.open('openjpa/Linking_Commit_to_Bug_Creation.txt', 'a') do |output|
  IO.foreach('openjpa/Linking_Commit_to_Bug.txt') do |line3|
    @commit = line3.match(/^(.*)(?=,)/)
    @bug = line3.match(/OPENJPA-.*\d/)
    IO.foreach('OpenJPA-JIRA/json/OPENJPA_Bugs_dates.json') do |line4|
      line4.chomp
      if (line4 =~ /#@bug,/)
        @bugCreationDate = line4.match(/[^,]*$/)
        output.puts"#{@commit},#{@bugCreationDate}"
      end
    end
  end
end


