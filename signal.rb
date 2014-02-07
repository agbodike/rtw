require 'quote'

# 99 day rule signal
def n_day(symbol, days, offset = 0)
  # get the oldest lookup first
  past_y   = Quote.first(:symbol => symbol, :order => [:date.desc], :offset => (days + offset + 1))
  return 0 unless past_y      # return zero if no record found
  future_y = Quote.first(:symbol => symbol, :order => [:date.desc], :offset => (offset+1))
  past_t   = Quote.first(:symbol => symbol, :order => [:date.desc], :offset => (days + offset))
  future_t = Quote.first(:symbol => symbol, :order => [:date.desc], :offset => offset)

  query_str = 'SELECT max(price_high) FROM quotes WHERE symbol = ? AND date > ? AND date <= ?'
  today_max     = repository(:default).adapter.select(query_str, symbol, past_t.date, future_t.date)
  yesterday_max = repository(:default).adapter.select(query_str, symbol, past_y.date, future_y.date)

  today_max <=> yesterday_max
end

def run_n_day(symbol, days, iterations)
start_time = Time.new   # Start timing here since everything above is just setup
  signal = 'N'
  puts signal
  (0..iterations).to_a.reverse.each do |i|
    result = n_day(symbol, days,i)
    if result == 1
      date = Quote.first(:symbol => symbol, :order => [:date.desc], :offset => i).date
      puts "#{date} - i: #{i} - Buy" if (signal == "Sell" || signal == "N")
      signal = 'Buy'
    elsif result == -1
      date = Quote.first(:symbol => symbol, :order => [:date.desc], :offset => i).date
      puts "#{date} - i: #{i} - Sell" if (signal == "Buy" || signal == "N")
      signal = 'Sell'
    end
  end
end_time = Time.now
puts "Execution time: %.2f seconds" % (end_time - start_time)
  nil
end
