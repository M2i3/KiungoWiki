require 'spec_helper'

describe VarPrecisionDate do

  describe "Verify creation" do
    it "creation is correct with the year only" do
      lambda { VarPrecisionDate.new("2007") }.should_not raise_error

    end
    it "creation is correct with the year and month only" do
      lambda { VarPrecisionDate.new("2007-05") }.should_not raise_error

    end
    it "creation is correct with the year, month and day" do
      lambda { VarPrecisionDate.new("2007-05-30") }.should_not raise_error

    end
  end

  describe "Verify validity" do
    it "invalid dates are detected" do
      lambda { VarPrecisionDate.new("2006-06-31") }.should raise_error
    end
    it "invalid month numbers are detected" do
      lambda { VarPrecisionDate.new("2005-13") }.should raise_error
    end
    it "check for validation for invalid non bisectile year" do
      lambda { VarPrecisionDate.new("2007-02-29") }.should raise_error
    end
  end

end

