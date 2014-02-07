#!/usr/bin/ruby

require 'quote'
require 'pp'
require 'command_line'
require 'util'
require 'progressbar'     # use to create a progressbar while script is executing

dates = ['1986-07-14', '1987-09-14', '1989-10-11', '1989-11-01', '1990-06-27', '1991-12-02', '1993-11-03', '1994-01-25', '1994-09-19', '1995-10-09', '1996-06-12', '1997-12-11', '1998-02-22', '1998-07-21', '1999-06-15', '2000-01-24', '2000-07-26', '2000-09-15', '2001-03-12', '2001-06-20', '2002-06-20', '2004-04-13', '2005-09-21', '2006-04-07', '2007-06-13', '2007-10-16', '2008-06-06', '2010-08-20']
#dates = ['2010-08-20','2008-06-06','2007-10-16','1986-07-14']
symbol = '^GSPC'

days_arr = [5,10,21,42,63,125,252]
#days_arr = [1,3,5,10,21,42,63]

db = repository(:default).adapter

results = []
dates.each do |date|
  q_hash = {}
  q_hash[:subject] = Quote.all(:conditions => {:date.gte => date, :symbol => symbol}, :order => [:date.asc], :limit => 1)
  days_arr.each do |d|
    q_hash[d] = Quote.all(:conditions => {:date.gte => date, :symbol => symbol}, :order => [:date.asc], :limit => 1, :offset => d)
  end

  limit = days_arr.max + 1    # add 1 to include the last day of the test period
  max_val_query_string = "SELECT max(price_close) FROM (SELECT date,price_close FROM quotes WHERE symbol=? AND date>=? ORDER BY date ASC LIMIT ?)"
  max_val = db.select(max_val_query_string, symbol, date, limit)[0]

  min_val_query_string = "SELECT min(price_close) FROM (SELECT date,price_close FROM quotes WHERE symbol=? AND date>=? ORDER BY date ASC LIMIT ?)"
  min_val = db.select(min_val_query_string, symbol, date, limit)[0]

  row_query_string = "SELECT date,price_close FROM quotes WHERE symbol=? AND date>=? AND price_close=? ORDER BY date ASC LIMIT ?"
  q_hash[:max] = db.select(row_query_string, symbol, date, max_val, limit)[0]
  q_hash[:min] = db.select(row_query_string, symbol, date, min_val, limit)[0]

  results << q_hash
end

header_str = []
days_arr.each {|d| header_str << "#{d}_day"}
header_str << "    min\t      date\t    max\t      date"
puts "Date\t   close_price\t" + header_str.join("\t")
#puts "Date close_price " + header_str.join(' ')     #pretty

#pp results
results.each do |result|
  tmp = []
  #days_arr.each {|d| p result[d][0].price_close}
  subject_close = result[:subject][0].price_close
  days_arr.each do |d|
    if result[d][0]       # Check if any results were returned for this day
      close = result[d][0].price_close
      percent = ((close - subject_close)/subject_close*100.0).to_s
      tmp_str = "%6.2f\%" % percent
      #tmp_str = "%s\t%.2f\%" % [close, percent]
      #tmp_str = "%s (%.2f\%" % [close, percent]     #pretty
      #tmp_str += ')'     #pretty
    else                  # No results for this day
      tmp_str = ""
    end

    tmp << tmp_str
  end

  close = result[:min].price_close
  date = result[:min].date
  percent = ((close - subject_close)/subject_close*100.0).to_s
  tmp_str = "%6.2f\%" % percent
  tmp_str += "\t%s" % date
  tmp << tmp_str

  close = result[:max].price_close
  date = result[:max].date
  percent = ((close - subject_close)/subject_close*100.0).to_s
  tmp_str = "%6.2f\%" % percent
  tmp_str += "\t%s" % date
  tmp << tmp_str

  puts result[:subject][0].date + "\t#{subject_close.to_s}\t#{tmp.join("\t")}"
  #puts result[:subject][0].date + ": #{subject_close.to_s} - #{tmp.join(' - ')}"     #pretty
end
