require 'spec_helper'

describe IncDate do

  describe "verify creation with" do
    describe "a String initializer" do
      it "correct with the year only" do
        lambda { IncDate.demongoize("2007") }.should_not raise_error
        IncDate.demongoize("2007").to_s.should eql("2007")
      end
      
      it "correct with the year and month only" do
        lambda { IncDate.demongoize("2007-05") }.should_not raise_error
        IncDate.demongoize("2007-05").to_s.should eql("2007-05")      
      end
      
      it "correct with the year, month and day" do
        lambda { IncDate.demongoize("2007-05-30") }.should_not raise_error
        IncDate.demongoize("2007-05-30").to_s.should eql("2007-05-30")            
      end

      it "correct with the year, month and day format 2" do
        lambda { IncDate.demongoize("20070530") }.should_not raise_error
        IncDate.demongoize("20070530").to_s.should eql("2007-05-30")            
      end
    end
    
    describe "a Fixnum intializer" do
      it "is correct with the year only" do 
        lambda { IncDate.demongoize(2007) }.should_not raise_error
        IncDate.demongoize(2007).to_s.should eql("2007")
      end
    end
  end

  describe "Verify validity" do
    it "if invalid dates are detected" do
      lambda { IncDate.new("2006-06-31") }.should raise_error
      lambda { IncDate.demongoize("2006-06-31") }.should_not raise_error
      IncDate.demongoize("2006-06-31").should eql(nil)
    end
    it "invalid month numbers are detected" do
      lambda { IncDate.new("2005-13") }.should raise_error
      lambda { IncDate.demongoize("2005-13") }.should_not raise_error
      IncDate.demongoize("2005-13").should eql(nil)
    end
    it "check for validation for invalid non bisectile year" do
      lambda { IncDate.new("2007-02-29") }.should raise_error
      lambda { IncDate.demongoize("2007-02-29") }.should_not raise_error
      IncDate.demongoize("2007-02-29").should eql(nil)
    end
  end

end

