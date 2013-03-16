require 'spec_helper'

describe Duration do
  #
  # large size durations ref: http://wiki.answers.com/Q/What_is_the_longest_song_ever_recorded
  #
  let(:field) do 
    described_class
#    described_class.new(:test, :type=>Duration)
  end

  describe "#demongoize" do
    it "returns the duration from the seconds" do
      field.demongoize(180000000).to_s.should == "50000:00:00"
      field.demongoize(3607).to_s.should == "1:00:07"
      field.demongoize(3599).to_s.should == "59:59"
      field.demongoize(3557).to_s.should == "59:17"
      field.demongoize(121).to_s.should == "2:01"
      field.demongoize(21).to_s.should == "21"
      field.demongoize(7).to_s.should == "7"
    end
  end


  describe "#mongoize" do 
    it "returns the duration in seconds" do
      field.mongoize("1:31").should == 91
      field.mongoize("26:65").should == 1625
      field.mongoize(5489).should == 5489
      field.mongoize("50000:00:00").should == 180000000
      field.mongoize({:hours=>50000}).should == 180000000
    end
    it "returns nil" do 
      field.mongoize(nil).should be_nil
    end
  end

end

