#!/usr/bin/ruby

require 'quote'
require 'pp'
require 'command_line'
require 'util'
require 'progressbar'     # use to create a progressbar while script is executing

options = CommandLineOption.new

OptionParser.new do |opts|
  options.set_options(opts)
end.parse!

# calculates the percent change between to prices, need to multiply by 100 if an
#   actual percentage is desired, rather than the decimal percentage
def calc_percent (start_price, end_price)
  tmp = (end_price.to_f - start_price.to_f) / start_price.to_f
end

# determines if a profit-latch or stoploss event has happened
# Params:
#   * pl:          Integer - the profit_latch value
#   * sl:          Integer - the stop_loss value
#   * test_item:   rtw_array.last
#   * symbol:      String  - the symbol to test
#   * offset:      Integer - trading day to check for
#
# Returns:
#   * the entry for the trade if a stop-loss or profit latch is triggered, otherwise
#   * false
def trade_latch(pl, sl, test_item, old_sym, offset)
  if (pl || sl)                                               # no pl or sl set, no need to go further
    if ((test_item[:buy] != '$') && (pl || sl))               # no need to go further as stop-loss or
                                                              # profit-latch has already been triggered
      tq = Quote.first(:symbol=>old_sym, :order=>[:date.desc], :offset=>offset)
      tmp_change = calc_percent(test_item[:buy_price], tq.price_adj_close) * 100
      tmp_entry = {:offset => offset, :date => tq.date, :sell => old_sym, :sell_price => tq.price_adj_close, :buy => '$', :buy_price => 1.0}

      pl ? (return tmp_entry if (tmp_change > pl)) : nil      # profit latch
      sl ? (return tmp_entry if (tmp_change < sl)) : nil      # stop loss
    end
  end

  return false                                                   # neither condition met
end

# determines if the specified lookback(s) is positive, and returns a
#   cash hold if not
# Params:
#   * type:            Symbol  - the options.lp setting which determines which
#                                lookback(s) to require to be positive
#   * own:             String  - the symbol that is currently being held, used to
#                                determine if cash is currently being held
#   * lookback_info:   Array   - the portion of the array from calculate_winners that
#                                includes the lookback info for the relevant symbol
#   * symbol:          String  - the symbol that would be held if not in cash
#   * offset:          Integer - trading day to check for
#
# Returns:
#   * the entry for the trade if a stop-loss or profit latch is triggered, otherwise
#   * false
# TODO: figure out how to get back into a symbol when it turns back to positive
# NOTE: this may not work well with pl or sl
def lookback_positive(type, own, lookback_info, symbol, offset)
  tmp_entry = false
  if (own == '$')
    case type
    when :first
      if lookback_info[1]
        quote = Quote.first(:symbol=>symbol, :order=>[:date.desc], :offset=>offset)
        tmp_entry = {:offset=>offset, :date=>quote.date, :sell=>'$', :sell_price=>1.0, :buy=>symbol, :buy_price=>quote.price_adj_close}
      end
    when :second
      if lookback_info[2]
        quote = Quote.first(:symbol=>symbol, :order=>[:date.desc], :offset=>offset)
        tmp_entry = {:offset=>offset, :date=>quote.date, :sell=>'$', :sell_price=>1.0, :buy=>symbol, :buy_price=>quote.price_adj_close}
      end
    when :both
    end
  else
    case type
    when :first
      unless lookback_info[1]
        quote = Quote.first(:symbol=>symbol, :order=>[:date.desc], :offset=>offset)
        tmp_entry = {:offset=>offset, :date=>quote.date, :sell=>symbol, :sell_price=>quote.price_adj_close, :buy=>'$', :buy_price=>1.0}
      end
    when :second
      unless lookback_info[2]
        quote = Quote.first(:symbol=>symbol, :order=>[:date.desc], :offset=>offset)
        tmp_entry = {:offset=>offset, :date=>quote.date, :sell=>symbol, :sell_price=>quote.price_adj_close, :buy=>'$', :buy_price=>1.0}
      end
    when :both
    end
  end if type

  return tmp_entry
end

old_symbol = nil
c_pct = 1.0
rtw_array = []
start_time = Time.new   # Start timing here since everything above is just setup

p options if options.verbose
puts ''

flag = 0
end_offset = options.iterations * options.trading_gap + options.start  #  determine the last day of the trading range
trading_range = ((options.start)..end_offset)  # set up the range of days to loop over
trading_range.to_a.reverse.each do |offset|    # loop over the range of days, starting in the past and moving forward

  # check if this is a day to check for if a switch has occurred (based on trading gap)
  trading_day = ((offset - options.start) % options.trading_gap == 0)
  # if weekday trading is set, check to see if this is a the right day of the week to check trades
  trading_day = Date.strptime(Quote.first(:symbol=>'SPY', :offset=>offset, :order=>[:date.desc]).date).strftime('%a').downcase == options.weekday.to_s if options.weekday

  # this is the basic functionality for alternate week trading, need to expand it to allow for arbitrary weekly gaps between trade checks
  if trading_day
    if flag % options.week_gap != 0
      trading_day = false
    end
    flag += 1
  end

  if trading_day
    result = Quote.calculate_winner(options.symbols, options.lookback[0], options.lookback[1], offset, options.ma)

    # determine if the symbol has dropped below the HTD threshold,
    # also indicates the initial state of no stock purchased
    dropped = result[1][0,options.htd].find {|x| x[0] == old_symbol } == nil
    tmp = result[1].detect{|x| x[0] == old_symbol}         # get the entry for the dropped symbol
    # and check to see if it has fallen far enough (below the drop threshold) to trigger a switch
    dropped = result[1][0][1][0] > (tmp[1][0] + options.dt) if (dropped && tmp)

    if dropped                       # the symbol has dropped below the HTD threshold, so get the info for the trades
      printf('.')                    # just used to show progress in running the backtest
      $stdout.flush                  # force printout of previous line so progress is displayed
      bq = Quote.first(:symbol => result[1][0][0], :date.gte => result[0], :order => [:date], :offset => (options.delay_sell + options.delay_buy))
      # NOTE: the buy/sell quote queries fail if a switch occurs on the last day in the DB. Because of this the result must be checked
      #   to ensure there is a proper result returned, and if not get the most recent quote for the symbol.
      if bq                       # buy quote was properly retrieved from the DB
        tmp = {:offset => offset, :date => result[0], :buy => result[1][0][0], :buy_price => Float(bq.price_adj_close)}
      else                        # buy quote was not retrieved - meaning a switch happened on the last day of DB information
	# get the most recent quote since the previous quote failed
      	bq = Quote.first(:symbol => result[1][0][0], :date.gte => result[0], :order => [:date])
        tmp = {:offset => offset, :date => result[0], :buy => result[1][0][0], :buy_price => Float(bq.price_adj_close)}
      end
      if old_symbol
        # NOTE: the line below might need to add the variable offset to the :offset parameter,
        #   check it out, it might be getting the wrong value... but maybe not since I don't
        #   think the numbers changed when I moved things in here from the section that sets
        #   up the string output information.
        sq = Quote.first(:symbol => old_symbol, :date.gte => result[0], :order => [:date], :offset => options.delay_sell)

        if (old_symbol != rtw_array.last[:buy])                # means the stoploss or profit latch was triggered
          tmp[:sell], tmp[:sell_price] = rtw_array.last[:buy], rtw_array.last[:buy_price]
        else                                                   # means it is a normal trade
          if sq                       # sell quote was properly retrieved from the DB
            tmp[:sell], tmp[:sell_price] = old_symbol, (sq.price_adj_close)
          else                        # sell quote was not retrieved - meaning a switch happened on the last day of DB information
	    # get the most recent quote since the previous quote failed
            sq = Quote.first(:symbol => old_symbol, :date.gte => result[0], :order => [:date])
            tmp[:sell], tmp[:sell_price] = old_symbol, (sq.price_adj_close)
          end
        end
      end

      # if start-fresh is set, don't record the initial mid-signal purchase, only start with the next fresh signal
      options.start_fresh ? (options.start_fresh = false) : (rtw_array << tmp)

      old_symbol = result[1][0][0]
    else
      tmp = trade_latch(options.profit_latch, options.stop_loss, rtw_array.last, old_symbol, offset) if rtw_array.last
      tmp = lookback_positive(options.lp, rtw_array.last[:buy], result[1][0][1], old_symbol, offset) unless tmp
      rtw_array << tmp if tmp
      
    end
  else          # not a trading gap day, don't check for winners/ normal trades, can check for stoploss/profit latch
    if (offset < end_offset)
      tmp = trade_latch(options.profit_latch, options.stop_loss, rtw_array.last, old_symbol, offset) if rtw_array.last
      rtw_array << tmp if tmp
    end
  end
end

puts ''
puts ''

final_quote = Quote.first(:symbol=>old_symbol, :order=>[:date.desc], :offset=>options.start)
if (rtw_array.last[:buy] != '$') then rtw_array << {:date => final_quote.date, :offset => options.start, :sell_price => final_quote.price_adj_close, :sell => old_symbol}
else rtw_array << {:date => final_quote.date, :offset => options.start, :sell_price => 1.0, :sell => '$'}
end
len = rtw_array.length

drawdown = []
rtw_array.each_with_index do |x,i|
  percent = (i > 0) ? calc_percent(rtw_array[i-1][:buy_price],x[:sell_price]) : 0.0
  rtw_array[i][:pct] = percent

  if i > 0
    if rtw_array[i-1][:buy] != '$'
      tmp = [rtw_array[i-1][:buy], Quote.get_min(rtw_array[i-1][:buy],rtw_array[i-1][:date],x[:date])[0]]
      tmp << calc_percent(rtw_array[i-1][:buy_price],tmp[1]) * 100 
      drawdown << tmp
    end
  end
  
  c_pct = c_pct * (1.0 + percent)
  rtw_array[i][:cumulative_pct] = c_pct
end

rtw_first = rtw_array.first
start_date = Date::strptime(rtw_first[:date])
tmp = ' '*24
puts "%4d - %10s (%s):#{tmp} buy %5s @ %8.2f" % [rtw_first[:offset], rtw_first[:date], Date.strptime(rtw_first[:date]).strftime('%a'), rtw_first[:buy], rtw_first[:buy_price]] if options.verbose

rtw_array[1..(len-2)].each_with_index do |x,i|
  str =  "%4d - %10s (%s): sell %5s @ %8.2f - " % [x[:offset], x[:date], Date.strptime(x[:date]).strftime('%a'), x[:sell], x[:sell_price]]
  str += "buy %5s @ %8.2f (%6.2f\%" % [x[:buy], x[:buy_price], x[:pct]*100]
  str += " ) - cumulative: %6.1f\%" % (x[:cumulative_pct]*100)
  puts str
end if options.verbose

rtw_last = rtw_array.last
end_date = Date::strptime(rtw_last[:date])
final =  "%4d - %10s (%s):  own %5s @ %8.2f - " % [rtw_last[:offset], rtw_last[:date], Date.strptime(rtw_last[:date]).strftime('%a'), rtw_last[:sell], rtw_last[:sell_price]]
final += ' '*20 + " (%6.2f\%" % (rtw_last[:pct]*100)
final += " ) - cumulative: %6.1f\%" % (rtw_last[:cumulative_pct]*100)
puts final if options.verbose
puts '' if options.verbose

years = (end_date - start_date) / 365.25
cagr = ((rtw_last[:cumulative_pct] ** (1.0/years)) - 1.0) * 100

# NOTE: this drawdown is only for 1 hold at a time, it is not a cumulative drawdown, need to add that later
drawdown.sort!{|a,b| a[2] <=> b[2]}

end_time = Time.now
puts "Execution time: %.2f seconds" % (end_time - start_time)
puts  "%i transactions, %.1f tx/year" % [rtw_array.length.to_s,(rtw_array.length / years)]

stats_str = "CAGR: %.2f\%" % cagr
stats_str += " | %.2f years" % years
stats_str += " - %i trades" % (rtw_array.length - 1)
stats_str += " | max DD: (%s) %.2f\%" % [drawdown[0][0],drawdown[0][2]]
puts stats_str
puts ''
#pp rtw_array
#pp drawdown

