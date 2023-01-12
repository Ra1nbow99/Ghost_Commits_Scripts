#!/usr/bin/env ruby

#Create array containing all commit numbers
all_commits = Array.new
File.open('All_Commit_Numbers.txt').each { |line| all_commits << line }
total_commits = all_commits.length

#Create array containing bug-fixing commit numbers
bug_fixing_commits = Array.new
File.open('Not_add_only_BFC_numbers.txt').each { |line| bug_fixing_commits << line }

#puts all_commits.find_index("0bb4a5c3ab43b0f10f4a255f134de5b8533eb67d" + "\n")



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

counting_array = Array.new
index = 0
prevcommit2Results.each do |prevCommit, files2Results|

  files2Results.each do |file, results|
    for result in results 
      #if !file.empty?
        #puts file
        #puts "first: ", result.first
        #puts "last: ", result.lastt 
        # git blame prevCommit file -L firts,last
        #command = "git blame #{prevCommit} #{file} -L #{result.first},#{result.last}"
        #puts command
        #get the bug-fixing commit, that's the one associated with the bug
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

index += 1
end
#puts(counting_array)
all_unique_implic_commits = []
surviving_unique_implic_commits = []
total_not_add_only_BFC = counting_array.length
ghost_commits = 0
fatalcounter = 0

index=0
for each in counting_array
    index+=1
  yes_ghost = true
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


      if line.start_with?("^") 
        yes_ghost = false
        if !surviving_unique_implic_commits.include?(impl1)
          surviving_unique_implic_commits << impl1
        end
        break
      end
    end
    if yes_ghost
      ghost_commits +=1 
    end
    #if ( (splitLines.all? {|line|  !line.start_with?("^")  && !line.start_with?("fatal")})   )
      #not_ghost_commits += 1
    #end
  end
end


all_unique_implic_commits_count = all_unique_implic_commits.length
all_surviving_implic_commits_count = surviving_unique_implic_commits.length



File.open('Unique_Implic_Commits', 'w+') do |f|
  f.puts(all_unique_implic_commits)
end

File.open('Surviving_Unique_Implic_Commits', 'w+') do |f1|
  f1.puts(surviving_unique_implic_commits)
end



puts "Fatal Counter: #{fatalcounter}"
puts "Filtering Ghosts: #{ghost_commits}"
puts "Total Not Add Only BFC: #{total_not_add_only_BFC}"
FG_Ratio = ((ghost_commits.to_f)/total_not_add_only_BFC)*100
puts "Filtering Ghosts ratio: #{FG_Ratio} %"
puts " "
puts " "
puts "All Unique Implic Commits: #{all_unique_implic_commits_count}"
before_Filter_Ratio = ((all_unique_implic_commits_count.to_f)/total_commits)*100
puts "All Unique Implic Commits Ratio: #{before_Filter_Ratio}"
puts "All Surviving Unique Implic Commits: #{all_surviving_implic_commits_count}"
after_Filter_Ratio = ((all_surviving_implic_commits_count.to_f)/total_commits)*100
puts "All Surviving Implic Commits Ratio: #{after_Filter_Ratio}"
#puts ((not_ghost_commits.to_f/total_not_add_only_BFC) * 100)























