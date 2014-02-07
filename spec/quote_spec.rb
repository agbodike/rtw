require '../quote.rb'

DataMapper.setup(:default, "sqlite3:stock_quotes.db")

describe Quote, "#get_lookbacks" do
  it "returns an array with values [?, ?, ?, lookback-1, lookback-2, date]" do
    result = Quote.get_lookbacks('SPY',50,235)
    result.should == [113.64, 104.09, 81.23, 50, 235, "2010-01-15"]
  end
  it "returns an array with values [?, ?, ?, lookback-1, lookback-2, date]" do
    result = Quote.get_lookbacks('QQQQ',50,235)
    result.should == [46.47, 41.19, 30.17, 50, 235, "2010-01-15"]
  end
  it "returns an array with values [?, ?, ?, lookback-1, lookback-2, date]" do
    result = Quote.get_lookbacks('EWZ',50,235)
    result.should == [73.54, 68.78, 36.35, 50, 235, "2010-01-15"]
  end
end

#describe Quote, "#get_normalized_growth" do
#  it "returns an array with values [?, ?, ?, lookback-1, lookback-2, date]" do
#    result = Quote.get_lookbacks('SPY',50,235)
#    result.should == [113.64, 104.09, 81.23, 50, 235, "2010-01-15"]
#  end
#  it "returns an array with values [?, ?, ?, lookback-1, lookback-2, date]" do
#    result = Quote.get_lookbacks('QQQQ',50,235)
#    result.should == [46.47, 41.19, 30.17, 50, 235, "2010-01-15"]
#  end
#  it "returns an array with values [?, ?, ?, lookback-1, lookback-2, date]" do
#    result = Quote.get_lookbacks('EWZ',50,235)
#    result.should == [73.54, 68.78, 36.35, 50, 235, "2010-01-15"]
#  end
#end

describe Quote, "#calculate_winner is passed the values (['GLD','EWZ','SHV'], 50, 235, 0, 5)" do
  before(:all) do
    @result = Quote.calculate_winner(["GLD","EWZ","SHV"], 50, 235, 0, 5)
  end

  #Can't compare the arrays directly because of floating point math
  it 'returns an array with the 0th element a string formatted date of "2010-01-15"' do
    @result[0].should == "2010-01-15"
  end

  it 'returns an array with the 1st element an array: ["EWZ", [0.274087531656564, true, true]]' do
    @result[1][0][0].should == "EWZ"
    @result[1][0][1][0].should be_close(0.274087531656564,0.000000000000001)  # Floating points are not precise
    @result[1][0][1][1].should == true
    @result[1][0][1][2].should == true
  end

  it 'returns an array with the 2nd element an array: ["GLD", [0.115873966243353, true, true]]' do
    @result[1][1][0].should == "GLD"
    @result[1][1][1][0].should be_close(0.115873966243353,0.000000000000001)  # Floating points are not precise
    @result[1][1][1][1].should == true
    @result[1][1][1][2].should == true
  end

  it 'returns an array with the 3rd element an array: ["SHV", [0.000682001469578828, true, true]]' do
    @result[1][2][0].should == "SHV"
    @result[1][2][1][0].should be_close(0.000682001469578828,0.000000000000000001)  # Floating points are not precise
    @result[1][2][1][1].should == true
    @result[1][2][1][2].should == true
  end
end
