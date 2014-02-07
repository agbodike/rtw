#!/usr/bin/ruby

require 'net/http'
require 'market_stat'
require 'optparse'
require 'optparse/time'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: optparse1.rb [options] file1 file2 ..."

  # Define the options, and what they do
  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end

  options[:date] = false
  opts.on( '-d', '--date DATE', Time, 'Retreive data for a specific date DATE (formate YYYY/MM/DD)' ) do |time|
    options[:date]  = time
    options[:year]  = time.strftime('%Y')
    options[:month] = time.strftime('%m')
    options[:day]   = time.strftime('%d')
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

attrs = [:market, :date, :adv_issues, :dec_issues, :unch_issues, :adv_volume, :dec_volume, :unch_volume, :new_highs, :new_lows]

resp = nil
Net::HTTP.start("unicorn.us.com") do |http|
  if !options[:date]
    resp = http.get("/advdec/recent.txt")
  else
    resp = http.get("/advdec/#{options[:year]}/adU#{options[:year]}#{options[:month]}#{options[:day]}.txt")
  end
end

tmp = resp.body.split("\n")                  # get the body of the request and split into an array for each line
date = tmp[0].gsub(/\//,'-')                 # First line is date - change '/' to '-'
tmp2 = tmp[2..4]                             # Market data is the 3rd - 5th lines

tmp3 = []
tmp2.each do |line|                          # For each line of market data
  tmp3 << line.split(',').each{|v| v.strip!}   # break into an array and strip off white space
end
tmp3.each {|v| v.insert(1,date)}               # Insert the date in the appropriate position

data = []
tmp3.each {|line| data << (Hash[*attrs.zip(line).flatten])}

begin
  data.each do |datum|
    stat = MarketStat.new
    stat.attributes = datum
    stat.save
  end
rescue DataObjects::IntegrityError
  if options[:date] then puts "Couldn't save for date: #{options[:year]}-#{options[:month]}-#{options[:day]}"
  else puts "Couldn't save for /advdec/recent.txt"
  end
rescue Exception => e
  puts "unknown error:"
  puts "#{ e } (#{ e.class })!"
end
