require '../util.rb'

describe Util, ".ema_weight" do
  it "returns 0.25 on a period of 7" do
    weight = Util.ema_weight(7)
    weight.should == 0.25
  end
  it "returns 0.2 on a period of 9" do
    weight = Util.ema_weight(9)
    weight.should == 0.2
  end
  it "returns 0.1 on a period of 19" do
    weight = Util.ema_weight(9)
    weight.should == 0.2
  end
end


describe Util, ".ema" do
  data = [1,2,3,4,5]
  data2  = [60.33,59.44,59.38,59.38,59.22,59.88,59.55,59.50,58.66,59.05,57.15,57.32,57.65,56.14,55.31,55.86,54.92,53.74,54.80,54.86]
  data3 =  [1.5554, 1.5555, 1.5558, 1.556]

  it "set last parameter to an array equal to [2.0, 3.0, 4.0] when given a period of 3 and input of [1,2,3,4,5]" do
    ema = Util.ema(3,data)
    ema.should == [2.0, 3.0, 4.0]
  end

  it "set last parameter to an array" do
    ema = Util.ema(10,data2)
    ema.should == [59.439, 59.023, 58.713, 58.52, 58.087, 57.582, 57.269, 56.842, 56.278, 56.009, 55.8]
  end

  it "returns 1.556" do
    ema = Util.ema(4,data3)
    ema.should == [1.556]
  end

end
