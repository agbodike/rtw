class Util
  def Util.ema_weight (period)
    (2 / (period.to_f + 1) )
  end
  
  # Standard period based Exponential Moving Average
  # params:
  #   n:     Integer - The number of periods to calculate the EMA
  #   data:  Array   - The data to be evaluated, oldest data at index 0
  #                    each element must be a number
  # NOTE: As EMA is calculated as an infinite series, the data paramater should have at least about three times
  #       the number of entries as the periods (n) in the EMA, example an EMA of 5 periods should have a data
  #       array with about 15 entries
  #
  def Util.ema(n, data)
    results = []
    tmp = data.clone
    weight = ema_weight n

    # Calculate SMA on beginning portion of array (the first 'n' elements)
    start = tmp.slice!(0..(n-1))
    results << ((start.inject(0.0) { |sum,el| sum + el } / start.size)*1000).round / 1000.0  # Calculate average

    tmp.each_with_index do |price,i|
      prev_ema = results[i]
      results << ((prev_ema + (weight * (price - prev_ema)))*1000).round / 1000.0
    end

    return results
  end
  
  # Simple Moving Average
  # TODO: haven't actually made this work at all, just copied from EMA and deleted a few obviously unneded lines
  #
  def Util.sma(n, data)
    results = []
    tmp = data.clone
    iterations = tmp.length - n
puts iterations

    # Calculate SMA on each 'n' elements chunk
    (0..iterations).each do |i|
      start = tmp.slice(i..(n+i-1))
      results << ((start.inject(0.0) { |sum,el| sum + el } / start.size)*1000).round / 1000.0  # Calculate average
    end

    return results
  end

  # Standard Weighted Moving Average
  # TODO: haven't actually made this work at all, just copied from EMA and deleted a few obviously unneded lines
  #
  def Util.wma(n, arr)
    results = []
    tmp = arr.clone
    len = tmp.length
    if (n < len)
      price = tmp.pop
      result = ema(n, tmp, results) + (weight * (price - ema(n, tmp, [])))
    else
      result = tmp.inject(0.0) { |sum,el| sum + el } / tmp.size  # Calculate average
      #result = tmp.inject(:+).to_f / tmp.size  # More clever (proc to symbol conversion, was causing problems on ruby 1.8.6)
    end
  
    result = (result*1000).round / 1000.0
    results << result    # Round to the nearest thousandth
    return result
  end

  # McClellan Oscillator
  #   calculates the McClellan Oscillator (19 day EMA of Advances minus Declines) − (39 day EMA of Advances minus Declines)
  # params (Hash):
  #   market:  String  - The market to run the calculation on (as defined in the market_stats table)
  #   offset:  Integer - The number of trading days in the past to calculate for (O indicates the most recent data)
  #   date:    String  - The date to calculate the the oscillator on
  #
  def Util.mcclellan_oscillator(params = {:market => 'NYSE'})
    db = repository(:default).adapter

    # set up default parameter values
    market = params[:market] ? params[:market] : 'NYSE'
    offset = params[:offset] ? params[:offset] : 0
    date   = params[:date]   ? params[:date]   : false

    query_string = 'SELECT (adv_issues - dec_issues) FROM market_stats WHERE market=?' + (date ? " AND date<='#{date}'" : '') + ' ORDER BY date DESC LIMIT ? OFFSET ?'   # ratio of adjusted net advances
    query_string = 'SELECT (adv_iss - dec_iss) FROM ? WHERE' + (date ? " date<='#{date}'" : '') + ' ORDER BY date DESC LIMIT ? OFFSET ?'   # ratio of adjusted net advances - pinnacle database
    data = db.select(query_string, market, 120, offset).reverse
#p query_string
#p data

    ema_19 = ema(19, data)
    ema_39 = ema(39, data)

    ema_19.last - ema_39.last
  end

  # McClellan Oscillator (Ratio Adjusted)
  #   calculates the RANA (Ratio Adjusted Net Advances) McClellan Oscillator (19 day EMA of RANA) − (39 day EMA of RANA)
  #   RANA: (Advances - Declines)/(Advances + Declines)
  # params (Hash):
  #   market:  String  - The market to run the calculation on (as defined in the market_stats table)
  #   offset:  Integer - The number of trading days in the past to calculate for (O indicates the most recent data)
  #   date:    String  - The date to calculate the the oscillator on
  # this version is useful in that the values do not change merely due to changes in the underlying number of issues in the market
  #
  def Util.mcclellan_oscillator_rana(params = {:market => 'NYSE'})
    db = repository(:default).adapter

    # set up default parameter values
    market = params[:market] ? params[:market] : 'NYSE'
    offset = params[:offset] ? params[:offset] : 0
    date   = params[:date]   ? params[:date]   : false

    query_string = 'SELECT (adv_issues - dec_issues)*1000.0/(adv_issues + dec_issues) FROM market_stats WHERE market=?' + (date ? " AND date<='#{date}'" : '') + ' ORDER BY date DESC LIMIT ? OFFSET ?'   # ratio of adjusted net advances
    data = db.select(query_string, market, 120, offset).reverse

    ema_19 = ema(19, data)
    ema_39 = ema(39, data)

    ema_19.last - ema_39.last
  end

  # Hindenburg Omen Indicator
  #   Determines the dates that a Hindenburg Omen occured
  # params (Hash):
  #   market:  String - The market to run the indicator on. default - 'NYSE'
  #   percent: Float  - The percent cuttoff of new highs & new lows required to qualify the indicator - Default 2.2
  #
  def Util.hindenburg_omen(params = {})
    db = repository(:default).adapter
    result = []

    # set up default parameter values
    percent = params[:percent] ? params[:percent] : 2.2

    # For 'market_stats' table
    market  = params[:market]  ? params[:market]  : 'NYSE'
    query_string = "SELECT date FROM market_stats WHERE (new_highs * 100.0) / (adv_issues+dec_issues+unch_issues) > ? AND (new_lows * 100.0) / (adv_issues+dec_issues+unch_issues) > ? AND new_highs < (2 * new_lows) AND market=?"

    # For pinnacle database
    market  = params[:market]  ? params[:market]  : 'b1'
    query_string = "SELECT date FROM #{market} WHERE (new_highs * 100.0) / tot_iss > ? AND (new_lows * 100.0) / tot_iss > ? AND new_highs < (2 * new_lows)"

    data = db.select(query_string, percent, percent)
    data.each do |date|
      result << date if mcclellan_oscillator({:market=>market, :date=>date}) < 0 
    end

    return result
  end

  #TODO: the mcclellan oscilator can be abstracted to a generic oscillator that can be used in many different markets, as well as individual symbols,
  #      such as a NAHL indicator along EMA(6,NAHL) - EMA(20,NAHL).
  #      Create the functionality for this.
end
