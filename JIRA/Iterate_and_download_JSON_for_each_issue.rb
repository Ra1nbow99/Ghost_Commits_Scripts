#!/usr/bin/ruby

require 'rest_client'


(1..2729).each do |myid|
	puts myid
	begin
		resp = RestClient.get "https://issues.apache.org/jira/rest/api/latest/issue/OPENJPA-#{myid}"
		if (resp.code == 200)
			puts "OPENJPA-#{myid} found"
			File.open("json/OPENJPA_jira_issues.json", "a") do |file|
				file.puts "OPENJPA-#{myid}"
				file.write "#{resp.to_str}"
				file.puts " "
				file.puts " "
			end
		end
		sleep 0.1
	rescue RestClient::ResourceNotFound
		File.open("json/Errors.txt", "a") do |file|
			file.puts "OPENJPA-#{myid} skipped because not found"
		end
	rescue Errno::ECONNRESET 
		File.open("json/Errors.txt", "a") do |file|
			file.puts "OPENJPA-#{myid} caused an ECONNRESET error"
		end
	rescue RestClient::Unauthorized
		File.open("json/Errors.txt", "a") do |file|
			file.puts "OPENJPA-#{myid} caused an Unauthorized error"
		end
		sleep 2
	end
end

