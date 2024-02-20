#!/usr/bin/ruby

# Cross-platform Ruby-based tmpwatch
# Written by Toby

# SCRIPT VARIABLES LISTED BELOW

# Use the variable below to specify which directory this script will check
dirtomonitor = '/var/www/ziplip/zlserver/WEB-INF/tmp/attachConvert'

# Define desired file retention time in the below variable. The value should be in minutes.
# Files static longer than the specified timeframe will be deleted when this script is run
threshinminutes = 720

# Define log file location. Do not include a trailing slash.
logfilelocation = '/var/rubytmpwatch/logs'

# Redirect all output to timestamped log file.
$stdout.reopen("#{logfilelocation}"'\tw_log_'"#{Time.now.strftime('%Y%m%d-%H%M%S')}"'.log', "w")
$stdout.sync = true
$stderr.reopen($stdout)

# expand threshold variable to seconds
timethreshold = threshinminutes * 60

# store current time
mtimenow = Time.now
puts

filelist = Array.new

Dir.chdir("#{dirtomonitor}")

puts "Deleting files that haven't been touched in #{threshinminutes} minutes..."

# recursively retrieve list of all files in dirtomonitor
Dir["**/*\.*"].each do |file_name|
    # find modified time for file
    mtimelatest = File.mtime(file_name)
    # calculate difference between current time and file modified time
    timediffer = mtimenow.round - mtimelatest.round

    # if the file is older than the specified threshold, then...
    if timediffer > timethreshold then
        # if the file is old enough and a file (not dir) then add to deletion list
        if File.file?(file_name) then
            filelist << "#{file_name}"
        end
    end
end

# Delete files and print to stdout
filelist.each do |filedel|
    puts "#{filedel} delete:"
    puts File.delete("#{filedel}")

end

puts "Deleting empty directories...\n"

# recursively remove any empty directories leftover after files are deleted
puts Dir['**/'].reverse_each { |d| Dir.rmdir d if (Dir.entries(d) - %w[ . .. ]).empty? }
dd
puts
