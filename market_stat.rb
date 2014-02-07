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
class MarketStat
  include DataMapper::Resource
 
  # You can specify :serial (auto-incrementing, also sets :key to true):
  #property :id,         Integer, :serial => true
  # ...or the Serial custom-type which is functionally identical to the above:
  #property :id,         Serial
  # ...or pass a :key option for a user-set key like the name of a user:
  property :market,           String, :key => true
  property :date,             String, :key => true
  property :adv_issues,       Integer
  property :dec_issues,       Integer
  property :unch_issues,      Integer
  property :adv_volume,       Integer
  property :dec_volume,       Integer
  property :unch_volume,      Integer
  property :new_highs,        Integer
  property :new_lows,         Integer
end
