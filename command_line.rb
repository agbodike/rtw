require 'optparse'
require 'optparse/time'

IntegerArray = /^\d+$/
class OptionParser

  #
  # List of strings separated by ",".
  #
  accept(IntegerArray) do |s,|
    if s
      s = s.split(',').collect {|s| s.to_i if (s =~ IntegerArray)}
      s.delete nil
    end
    s
  end

end

class CommandLineOption
  attr_accessor :delay_buy, :delay_sell, :dt, :eom, :eom_days, :htd, :iterations, :lookback, :lp,
                :ma, :profit_latch, :start, :start_fresh, :stop_loss, :symbols, :trading_gap,
                :verbose, :week_gap, :weekday, :weighting
 
  @@preset_symbols = {
    :afam     => ["USO","GLD","SLV","EWZ","EWM","TLT"],             # NOTE: may work better than "test" below when combined
                                                                   # with a longer moving average
    :test     => ["USO","GLD","EWZ","EWM","TLT","ICF"],
    :original => ["DBA","DBC","EPP","EWJ","EWM","EWZ","EZA","GLD","IEV","ILF","IWM","SPY","TLT"],
    :dm       => ["BIL","BTTRX","EPP","EWJ","GLD","IEV","ILF","IWM","SPY"],
    :zee1     => ["ASA","BTTRX","EWJ","EWM","EWZ","EZA","GLD","IEV","ILF","LAQ","SASPX"],
    :zee2     => ["ASA","BTTRX","EPP","EWJ","EWM","EWZ","EZA","FIEUX","IEV","ILF","IWM","LAQ","SASPX","SPY","SWPIX","SWSMX"],
    :zee3     => ["DBA","DBC","EPP","EWJ","EWM","EWZ","EZA","GLD","IEV","ILF","IWM","SASPX","SHV","SPY","TLO","TLT"],
    :fc       => ["EWZ","ILF","EPP","EZA","EWM","SASPX","IWM","IEV","SPY","GLD","DBC","EWJ","DBA","SHV","TLO","TLT"],
    :amex_ss  => ["XLB","XLE","XLF","XLI","XLK","XLP","XLU","XLV","XLY"]
  }

  def initialize
    @delay_buy     = 0
    @delay_sell    = 1
    @dt            = 0.0
    @eom           = false
    @eom_days      = [5,1]          # superior six
    @htd           = 1
    @iterations    = 50
    @lookback      = [50,235]
    @lp            = false
    @ma            = 1
    @profit_latch  = false
    @start         = 0
    @start_fresh   = false
    @stop_loss     = false
    @trading_gap   = 5
    @verbose       = false
    @week_gap      = 1
    @weekday       = false
    @weighting     = 1.0

    set_symbols :afam
  end

  def set_symbols(preset)
    @symbols = @@preset_symbols[preset]
  end

  def set_options(opts)
    opts.banner = "Usage: " + __FILE__ + " [options]"
    opts.separator ""
    opts.separator "Common Options:"

    # Cast 'hold-til-drop' argument to a Integer.
    opts.on("-h", "--hold-til-drop N", Integer,
            "Hold the winner until it has dropped N positions") do |n|
      @htd = n
    end

    # Cast 'iterations' argument to a Integer.
    opts.on("-i", "--iterations N", Integer,
            "Run the test N periods back",
            "  DEFAULT: 100") do |n|
      @iterations = n
    end

    # Cast 'lookback' argument to an Array of Integers.
    opts.on("-l", "--lookback N[,N]*", IntegerArray,
            "The number of days per lookback in the format of an CSV",
            "  EXAMPLE: -l 40,200 will set the first lookback to 40",
            "    trading days and the second to 200 trading days",
            "  DEFAULT: 50,235") do |n|
      @lookback = n
    end

    # Cast 'moving-average' argument to a Integer.
    opts.on("-m", "--moving-average N", Integer,
            "Calculate quotes using a moving average of N days") do |n|
      @ma = n
    end

    # Cast 'offset' argument to a Integer.
    opts.on("-o", "--offset N", Integer,
            "Run the test starting N days in past",
            "  NOTE: must be a non-negative integer") do |n|
      @start = n
    end

    # Optional argument with keyword completion.
    opts.on("-p", "--preset [TYPE]", [:dm, :zee1, :zee2, :zee3, :amex, :afam, :test, :fc],
            "Use preset symbols (dm, zee1, zee2, zee3, amex, afam, test, fc)") do |t|
      set_symbols t
    end

    # Cast 'symbols' argument to an Array.
    opts.on("-s", "--symbols Str[,Str]*", Array,
            "Use the given set of symbols",
            "  NOTE: must be a csv of valid ticker symbols") do |n|
      @symbols = n
    end

    # Cast 'trading-gap' argument to a Integer.
    opts.on("-t", "--trading-gap N", Integer,
            "Check for trades every N days",
            "  NOTE: setting trading-gap will not change the number",
            "    of iterations, so test will run over",
            "    trading-gap * iterations days in the past",
            "  DEFAULT: 5") do |ary|
      @trading_gap = ary
    end

    # Cast 'weekday' to an Float
    opts.on("-w", "--weekday N", [:mon, :tue, :wed, :thu, :fri],
            "  only check on a given weekday, or the next trading",
            "    day if that day is a holiday") do |t|
      @weekday = t
    end


    # these are ideas to implement if desired
    opts.separator ""
    opts.separator "Advanced Options:"

    # Cast 'delay-buy' argument to a Integer.
    opts.on("--db N", "--delay-buy N", Integer,
            "Wait N days after selling the old stock before buying",
            "  the next holding.",
            "  DEFAULT: 0 (buy the same day as selling)") do |n|
      @delay_buy = n
    end

    # Cast 'delay-sell' argument to a Integer.
    opts.on("--ds N", "--delay-sell N", Integer,
            "Wait N days after a signal triggers before selling",
            "  the old stock.",
            "  DEFAULT: 1 (sell the day after a trade is signaled)") do |n|
      @delay_sell = n
    end

    # Cast 'drop-threshold' to an Integer
    #   this is an attempt to avoid whipsaw by preventing a stock from
    #   sold until it has fallen a little bit more than the position, not
    #   sure if this is clear, basically if a stock is in position 1, and
    #   then falls to position 2 (or lower if using htd) then it will not
    #   be sold until it has fallen by N below the now winning symbol
    #   - an inital estimate is for N to be 0.02, but more research is needed
    opts.on("--dt N", "--drop-threshold N", Float,
            "do not consider a stock to have dropped position until",
            "  it has dropped by N amount below the new winner") do |n|
      @dt = n
    end

    # Cast 'lookback-positive' to an Integer
    opts.on("--lp N", "--lookback-positive N", [:first, :second, :both],
            "Requires the specified lookback to be positive",
            "  options: first, second, both") do |t|
      @lp = t
    end

    # Cast 'profit-latch' to an Integer
    opts.on("--pl N", "--profit-latch N", Integer,
            "Sell the holding at a certain percent gain",
            "  and hold cash until the next signal") do |n|
      @profit_latch = n
    end

    # Cast 'stop-loss' to an Integer
    opts.on("--sl N", "--stop-loss N", Integer,
            "Sell the holding at a certain percent loss",
            "  and hold cash until the next signal") do |n|
      @stop_loss = -n
    end

    # Boolean switch.
    opts.on("--start-fresh", "Begin trading a the first fresh signal",
            "  this means cash will be held at the beginning of the",
            "  backtest until the first fresh buy signal occurs") do |b|
      @start_fresh = b
    end

    # Cast 'week-gap' to an Float
    opts.on("--wg", "--week-gap N", Integer,
            "  check for trades every Nth week, default is 1") do |n|
      @week_gap = n
    end


    ## these are ideas to implement if desired
    #opts.separator ""
    #opts.separator "Not yet implemented:"

    ## Cast 'positions' argument to a Integer.
    #opts.on("--positions N", Integer,
    #        "Hold the top N positions",
    #        "  NOTE: must be a positive integer") do |n|
    #  @positions = n
    #end

    ## Cast 'end-of-month' to an Integer
    #opts.on("--eom N,M", "--end-of-month N,M", IntegerArray,
    #        "Use the 'End-of-the-month' effect: only hold the",
    #        "  positions during the last N days and the first M",
    #        "  days of the month") do |ary|
    #  @eom = true
    #  @eom_days = ary
    #end

    ## Cast 'trailing-stop' to an Integer
    #opts.on("--ts N", "--trailing-stop N", IntegerArray,
    #        "Sell the position if it drops N percent below the",
    #        "  peak price set during a hold") do |ary|
    #  @eom = true
    #  @eom_days = ary
    #end

    ## Cast 'weighting' to an Float
    #opts.on("--weighting N", Float,
    #        "A floating point number that weights the first",
    #        "  lookback over the remaining lookbacks",
    #        "  EXAMPLE: a weight of 2.0 makes the first lookback",
    #        "    twice as important and a weight of 0.5 makes the",
    #        "    first lookback half as important") do |n|
    #  @weighting = n
    #end

    opts.separator ""
    opts.separator "Output Options:"

    # Boolean switch.
    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
      @verbose = v
    end

    # No argument, shows at tail.  This will print an options summary.
    opts.on_tail("--help", "Show this help message") do
      puts opts
      exit
    end
  end

end
