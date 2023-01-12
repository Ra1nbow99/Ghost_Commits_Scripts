#!/usr/bin/env ruby

#Create array containing all commit numbers
all_commits = Array.new
File.open('All_Commit_Numbers.txt').each { |line| all_commits << line }
total_commits = all_commits.length

#Create array containing bug-fixing commit numbers
bug_fixing_commits = Array.new
File.open('Surviving_Comments_Filter_BFC.txt').each { |line| bug_fixing_commits << line }

commitIDs_and_dates = File.open("Linking_Commit_to_Bug_Creation.txt").readlines
#commitIDs_and_dates.map {|x| x.chomp}

dates_hash = Hash.new

for each in commitIDs_and_dates
  each.delete!("\n")
  s = each.split(',')
  commit = s[0]
  date = s[1]
  dates_hash[commit] = date
end

#puts dates_hash
#break

#Creates array containing diffs between each bug-fixing commit and the previous commit
diffs_array = Hash.new
final_touch = Hash.new
for bfc in bug_fixing_commits
  bfc_index_in_all_commits = all_commits.find_index("#{bfc}")
  prev_commit_index = bfc_index_in_all_commits + 1
  prev_commit = all_commits[prev_commit_index]
  bfc1 = bfc.chomp
  prev_commit1 = prev_commit.chomp
  x = `git diff #{prev_commit1} #{bfc1}`
  diffs_array[prev_commit1] = x
  final_touch[prev_commit1] = bfc1
end

##
#Need to extract removed lines from each diff in the array, and run git blame on those removed line, with the
#previous commit that is being compared to

prevcommit2Results = Hash.new

diffs_array.each do |key, value|
   
  prevCommit = key 
  x= value 

  splitLines = x.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').split("\n")
  insideChunk = false
  miniChunkDone = false
  startLineToInt = 0
  lineNumbers = []
  result = []
  counter = 0
  newfile =false;
  insideSecondFile =false
  fileName = ""

  file2LineNumbers = Hash.new

  #for loop to get chunks
  splitLines.each_with_index do |line, index|
    if index == (splitLines.length - 1) #last iteration
      if !lineNumbers.empty?
        result.push(lineNumbers)
      end
      file2LineNumbers[fileName] =  result     #is this replacing or what???????
      result = []
    end
    if line.start_with?("diff") 
      if !fileName.empty?
        if !lineNumbers.empty?
            result.push(lineNumbers)
        end
        file2LineNumbers[fileName] =  result
        result = []
      end
      newfile = true
    end
    if newfile && line.start_with?("---") 
      s = line.split('/', 2)
      fileName = s[1]
      newfile = false
    end
    if insideChunk
      if !line.start_with?("+")
        counter+=1  
      end
      if line.start_with?( "-")
        lineNumbers << startLineToInt+ counter-1  
      elsif line.start_with?("@@") 
          if !lineNumbers.empty?
            result.push(lineNumbers)
            end
## PROBLEM HERE WITH LINE NUMBERS 
      end
      if line.start_with?("+")
        #lineNumbers << startLineToInt+ counter-1
        if !lineNumbers.empty?
            result.push(lineNumbers)
        end
        lineNumbers = []
        startLineToInt = startLineToInt+ counter-1 + 1
        counter = 0
      end
      if line.start_with?( "@@") || line.start_with?("diff")
        insideChunk = false
        startLineToInt = 0
        lineNumbers = []
        counter = 0
      end  
    end
    if line.start_with?( "@@")
      insideChunk = true
      #keep going until comma
      startline = []
      (4...10).each do |index1|
        if !line[index1].eql? ","
          startline << (line[index1])
        else
            break true
        end
      end
      startLineToInt = startline.join.to_i  
    end
  end
  prevcommit2Results[prevCommit] = file2LineNumbers
end

#puts prevcommit2Results

#EACH ENTRY IN THIS ARRAY WILL HAVE THE SAME INDEX AS COUNTING_ARRAY - SO WE KNOW WHICH BFC IS LINKED TO EACH COUNTING_ARRAY ENTRY
link_counting_to_bfc = []

counting_array = Array.new
index = 0
prevcommit2Results.each do |prevCommit, files2Results|
  files2Results.each do |file, results|
    #CHECK WHETHER IT IS A .txt FILE AND IGNORE IF SO
    (file.to_s).encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    if file.include? ".txt"
      # DO NOTHING ----------------------------------
    else # IF NOT A .txt FILE PROCEED NORMALLY
      for result in results 
          bfc = final_touch[prevCommit]
          creation_date = dates_hash[bfc]
          #puts creation_date
          n = "git blame -L #{result.first},#{result.last} --after=\"#{creation_date}\" #{prevCommit} -- #{file}"
          puts n
          m = `git blame -L #{result.first},#{result.last} --after="#{creation_date}" #{prevCommit} -- #{file}`
          puts m
          if m.empty?
            puts file 
          end
          m.encode('UTF-8', :invalid => :replace)
          m.scrub(" ")
          counting_array[index] = (counting_array[index]).to_s + m.to_s + " "
          #if counting_array[index].nil? || counting_array[index].empty?
            #puts (index)
           #puts("FARIDA")
            #puts n
          #ends
      end
    end
  end 
  #THIS ADDS THE BFC OF THE PREV_COMMIT AT THE SAME INDEX AS COUNTING_ARRAY
  link_counting_to_bfc << final_touch[prevCommit]
  index += 1
end



#puts(counting_array)
all_unique_implic_commits = []
surviving_date_unique_implic_commits = []
surviving_comments_unique_implic_commits = []
surviving_whitespace_unique_implic_commits = []
total_not_add_only_BFC = counting_array.length
ghost_commits = 0
fatalcounter = 0
surviving_Date_Filter_BFC = []
surviving_Comments_Filter_BFC = []
surviving_Whitespace_Filter_BFC = []


index=0
for each in counting_array
  yes_whitespace_ghost = true
  if each.nil?
    puts("each is nil??")
    puts(index) 
  elsif each.empty?
        fatalcounter+=1
  end
  if (!each.nil? && !each.empty?)
    splitLines = each.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').split("\n")
    splitLines.each do |line| 
      impl = (line.match(/^(\S*)/)).to_s
      # CHECKING WHETHER ALL UNIQUE IMPLIC COMMITS ALREADY CONTAINTS AN IMPLIC COMMIT AND ADDING IF NOT
      if line.start_with?("^")
        impl1 = impl[1..-1]
      else
        impl1 = impl
      end
      if !all_unique_implic_commits.include?(impl1)
        all_unique_implic_commits << impl1
      end
      # CHECKING WHETHER IMPLIC COMMIT HAPPENED BEFORE THE --AFTER DATE AND IF SO IT SURVIVES
      if line.start_with?("^") 
        #yes_ghost = false  - WE USED THIS FOR DATE FILTER NOT DOING THIS NOW FOR COMMENTS
        if !surviving_date_unique_implic_commits.include?(impl1)
          surviving_date_unique_implic_commits << impl1
        end
        #break
      end
      # INSERT LOGIC TO SPLIT THE LINE AFTER THE )
      line.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      halves = line.split(")",2)
      implic_Code = halves[1]
      #IF NIL OR EMPTY JUST ADD A SPACE
      implic_Code = implic_Code.to_s + " "
        wanted = implic_Code.match(/\A(.*?)\S+/).to_s.strip
        # CHECKING WHETHER AFTER THE SPLIT WE HAVE ANY OF THE CHARACTERS THAT SIGNIFY COMMENT
        if !((wanted == "//") || (wanted == "/*") || (wanted == "*") || (wanted == "<!")) 
          # IF NONE OF THE CHARACTERS - SO WE FOUND A LINE THAT IS NOT A COMMENT - SO NOT COMMENT GHOST
          #yes_comment_ghost = false
          if (surviving_date_unique_implic_commits.include?(impl1) &&
              !surviving_comments_unique_implic_commits.include?(impl1))
            surviving_comments_unique_implic_commits << impl1
          end  
        end  
      # WHITESPACE CHECK AND EXECUTE
      if (implic_Code.match(/\S/).nil?)  
        if (surviving_date_unique_implic_commits.include?(impl1) &&
           surviving_comments_unique_implic_commits.include?(impl1) &&
           !surviving_whitespace_unique_implic_commits.include?(impl1))
          surviving_whitespace_unique_implic_commits << impl1
        end 
      else
        yes_whitespace_ghost = false 
      end
    end
    if yes_whitespace_ghost
      #ghost_commits += 1 - DO NOTHING, WE'RE NOT COUNTING GHOST COMMITS ANYMORE
    else
      surviving_Whitespace_Filter_BFC << link_counting_to_bfc[index]
    end
    #if ( (splitLines.all? {|line|  !line.start_with?("^")  && !line.start_with?("fatal")})   )
      #not_ghost_commits += 1
    #end
  end
  index+=1
end


all_unique_implic_commits_count = all_unique_implic_commits.length
surviving_date_unique_implic_commit_count = surviving_date_unique_implic_commits.length
surviving_comments_unique_implic_commit_count = surviving_comments_unique_implic_commits.length
surviving_whitespace_unique_implic_commit_count = surviving_whitespace_unique_implic_commits.length




#File.open('Unique_Implic_Commits', 'w+') do |f|
  #f.puts(all_unique_implic_commits)
#end


File.open('Surviving_Whitespace_Unique_Implic_Commits.txt', 'w+') do |f1|
  f1.puts(surviving_whitespace_unique_implic_commits)
end

File.open('Surviving_Whitespace_Filter_BFC.txt', 'w+') do |f2|
  f2.puts(surviving_Whitespace_Filter_BFC)
end



#puts "Fatal Counter: #{fatalcounter}"
#puts "Filtering Ghosts: #{ghost_commits}"
#puts "Total Not Add Only BFC: #{total_not_add_only_BFC}"
#FG_Ratio = ((ghost_commits.to_f)/total_not_add_only_BFC)*100
#puts "Filtering Ghosts ratio: #{FG_Ratio} %"
#puts " "
#puts " "
#puts "All Unique Implic Commits: #{all_unique_implic_commits_count}"
#before_Filter_Ratio = ((all_unique_implic_commits_count.to_f)/total_commits)*100
#puts "All Unique Implic Commits Ratio: #{before_Filter_Ratio}"
#puts "All Unique Implic Commits Surviving Date Filter: #{surviving_date_unique_implic_commit_count}"
#after_Date_Filter_Ratio = ((surviving_date_unique_implic_commit_count.to_f)/total_commits)*100
#puts "All Surviving DATE FILTER Implic Commits Ratio: #{after_Date_Filter_Ratio}"
puts "All Unique Implic Commits Surviving Comments Filter: #{surviving_comments_unique_implic_commit_count}"
after_Comments_Filter_Ratio = ((surviving_comments_unique_implic_commit_count.to_f)/total_commits)*100
puts "All Surviving COMMENTS FILTER Implic Commits Ratio: #{after_Comments_Filter_Ratio}"
puts "All Unique Implic Commits Surviving Whitespace Filter: #{surviving_whitespace_unique_implic_commit_count}"
after_Whitespace_Filter_Ratio = ((surviving_whitespace_unique_implic_commit_count.to_f)/total_commits)*100
puts "All Surviving WHITESPACE FILTER Implic Commits Ratio: #{after_Whitespace_Filter_Ratio}"
#puts ((not_ghost_commits.to_f/total_not_add_only_BFC) * 100)























