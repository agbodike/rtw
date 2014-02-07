#
# Author::    Afam Agbodike
# Copyright:: Copyright (c) 2009 Afam Agbodike

require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'ministat'
require 'pp'

DataMapper.setup(:default, "sqlite3:db/stock_quotes.db")

# This class interfaces with the quote table and does basic manipulation
# on the data returned in order to find lookbacks, normalization, and
# determine the winning symbol based on RTW (Riding the Wave) methodology
class Quote
  include DataMapper::Resource
 
  # You can specify :serial (auto-incrementing, also sets :key to true):
  #property :id,         Integer, :serial => true
  # ...or the Serial custom-type which is functionally identical to the above:
  #property :id,         Serial
  # ...or pass a :key option for a user-set key like the name of a user:
  property :symbol,           String, :key => true
  property :date,             String, :key => true
 
  property :price_open,       Float
  property :price_high,       Float
  property :price_low,        Float
  property :price_close,      Float

  property :volume,           Integer
  property :price_adj_close,  Float

  # this function gets the adjusted close price for three data points:
  #   params:
  #     symbol:  the ticker symbol to look up
  #     lb_1:    the first lookback period in trading days
  #     lb_2:    the second lookback period in trading days, must be
  #              greater than lb_1
  #     offset:  used to shift all lookbacks and the start date by
  #              the given number of trading days
  #     ma:      the number of days by which to calculate a moving average
  #
  #   start_ma:  will be the subject date being determined
  #   lb_1_ma:   will be the first number of days to look back
  #   lb_2_ma:   will be the second number or days to look back
  #   date:      will be the date of the most recent lookup (starting date)
  #
  #   returns an array of the adjusted close price for the three data points
  #     plus the two lookback days ranges (which is later used by
  #     get_normalized_growth).
  #
  #   TODO: Add ability to do an EMA instead of just an SMA. (use function from util.rb).
  #         There will need to be changes, as we currently just pass the number of prices
  #         needed for an SMA, while ema's are built up from the beginning.
  #
  def Quote.get_lookbacks(symbol, lb_1, lb_2, offset=0, ma=1)
    start_quotes   = self.all(:symbol=>symbol, :offset=>offset, :order=>[:date.desc], :limit=>ma)
    lb_1_quotes    = self.all(:symbol=>symbol, :offset=>lb_1+offset, :order=>[:date.desc], :limit=>ma)
    lb_2_quotes    = self.all(:symbol=>symbol, :offset=>lb_2+offset, :order=>[:date.desc], :limit=>ma)

    start_prices = start_quotes.collect{|q| q.price_adj_close } if start_quotes
    start_ma = MiniStat::Data.new(start_prices).mean if (start_prices && start_prices != [])         # get average of prices
    lb_1_prices = lb_1_quotes.collect{|q| q.price_adj_close } if lb_1_quotes
    lb_1_ma = MiniStat::Data.new(lb_1_prices).mean if (lb_1_prices && lb_1_prices != [])             # get average of prices
    lb_2_prices = lb_2_quotes.collect{|q| q.price_adj_close } if lb_2_quotes
    lb_2_ma = MiniStat::Data.new(lb_2_prices).mean if (lb_2_prices && lb_2_prices != [])             # get average of prices

    date = start_quotes[0] ? start_quotes[0].date : nil

    return [start_ma, lb_1_ma, lb_2_ma, lb_1, lb_2, date]
  end

  # determines the normalized rate of return for the two lookback
  #   periods (meaning the average daily rate of return
  #
  # params:
  #   quotes: an array in the format returned by Quotes.get_lookbacks
  #   segment: whether to segment the lookbacks... meaning when segmented it
  #            calculates the return with no overlapping days. Otherwise all
  #            lookbacks are calculated from the start date.
  #
  # returns an array of the calculated daily growth rate of the two periods
  #   as a normalized value or nil if the array does not contains a nil entry.
  #   The normalized value is only a relative value used to compare the two growth
  #   rates, it is not the actual growth rate.
  #
  def Quote.get_normalized_growth(quotes, segment=true)
    if quotes.include?(nil): return nil
    else
      price_diff = quotes[0] - quotes[1]
      percent_change = price_diff / quotes[1]
      rate_1 =  Math.log(1.0 + percent_change)

      if segment
        num_days = quotes[4] - quotes[3]
        price_diff = quotes[1] - quotes[2]
      else
        num_days = quotes[4]
        price_diff = quotes[0] - quotes[2]
      end
      percent_change = price_diff / quotes[2]
      ratio = Float(num_days) / Float(quotes[3])
      rate_2 = Math.log(1.0 + percent_change) / ratio
    end

    return [rate_1, rate_2, quotes[5]]
  end

  # Calculates the winner of a set of symbols
  #   lb_1: the first number of trading days to look back
  #   lb_2: the second number of trading days to look back
  #   offset: the total numbers of trading days back to start (used to iterate
  #           back in time)
  #   segment: whether to segment the lookbacks... meaning when segmented it
  #            calculates the return with no overlapping days.
  #
  def Quote.calculate_winner(symbols, lb_1, lb_2, offset=0, ma=1, segment=true)
    trade_date = nil
    result = {}

    # TODO: should check to ensure that the trade date is the same for each symbol
    #   but probably in get_lookbacks
    symbols.each do |symbol|
      tmp = self.get_normalized_growth(self.get_lookbacks(symbol,lb_1, lb_2, offset, ma), segment)
      if tmp
        result[symbol] = [tmp[0] + tmp[1],(tmp[0] >= 0) ? true : false, (tmp[1] >= 0) ? true : false]
	trade_date = tmp[2]
      else result[symbol] = nil
      end
    end
    #pp result
    return [trade_date, result.delete_if{|k,v| v == nil}.sort {|a,b| b[1][0]<=>a[1][0]}]
  end

  # retrieves the max price on a symbol between the given dates
  def Quote.get_max(symbol, start_date, end_date)
    repository(:default).adapter.select("select max(price_adj_close) from quotes where symbol = ? and date >= ? and date <= ?", symbol, start_date, end_date)
  end

  # retrieves the min price on a symbol between the given dates
  def Quote.get_min(symbol, start_date, end_date)
    repository(:default).adapter.select("select min(price_adj_close) from quotes where symbol = ? and date >= ? and date <= ?", symbol, start_date, end_date)
  end

end
 
class Statistics

  def Statistics.growth_rate(start, stop, periods)
    ((start / stop) ** (1.0/periods) - 1.0) * 100.0
  end
end
