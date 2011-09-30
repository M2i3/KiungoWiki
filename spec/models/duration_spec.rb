require 'spec_helper'
require 'mongoid/fields/serializable/duration'

describe Mongoid::Fields::Serializable::Duration do
  #
  # large size durations ref: http://wiki.answers.com/Q/What_is_the_longest_song_ever_recorded
  #
  let(:field) do 
    described_class.instantiate(:test, :type=>Duration)
  end

  describe "#cast_on_read?" do 
    it "returns true" do 
      field.should be_cast_on_read 
    end  
  end

  describe "#deserialize" do
    it "returns the duration from the seconds" do
      field.deserialize(180000000).to_s.should == "50000:00:00"
      field.deserialize(3607).to_s.should == "1:00:07"
      field.deserialize(3599).to_s.should == "59:59"
      field.deserialize(3557).to_s.should == "59:17"
      field.deserialize(121).to_s.should == "2:01"
      field.deserialize(21).to_s.should == "21"
      field.deserialize(7).to_s.should == "7"
    end
  end


  describe "#serialize" do 
    it "returns the duration in seconds" do
      field.serialize("1:31").should == 91
      field.serialize("26:65").should == 1625
      field.serialize(5489).should == 5489
      field.serialize("50000:00:00").should == 180000000
      field.serialize({:hours=>50000}).should == 180000000
    end
    it "returns nil" do 
      field.serialize(nil).should be_nil
    end
  end

end

