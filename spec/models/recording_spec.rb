require 'spec_helper'

describe Recording do

	describe "Testing for required values" do 
		[:recording_date, :recording_location, :rythm].each {|field|	
			it "#{field} should allow nil" do 
				rec = Factory.build(:recording, field =>  nil)			
				rec.valid?.should == true
			end
		}
	
		[:duration].each {|field|	
			it "#{field} should not allow nil" do 
				rec = Factory.build(:recording, field =>  nil)			
				rec.valid?.should == false
				rec.errors[field].include?("can't be blank").should == true
			end
		}
	end
	
	describe "Testing for the duration" do	
		["a", nil, -15, 0].each {|value|
			it "when specified, duration should be numerical and greater than 0 (#{value} is not valid)" do
				rec = Factory.build(:recording, :duration=>value)
				rec.valid?.should == false
			end
		}
	
		[1, 15, 300, 10000, 500000, 1000000].each do |value|
			it "when specified, duration should be numerical and greater than 0 (#{value} is valid)" do
				rec = Factory.build(:recording, :duration=>value)
				rec.valid?.should == true
			end		
		end
	end
	
	describe "Testing for the rythm" do	
		["a", -15, 0].each {|value|
			it "when specified, rythm should be numerical and greater than 0 (#{value} is not valid)" do
				rec = Factory.build(:recording, :rythm=>value)
				rec.valid?.should == false
			end
		}
	
		[1, 15, 300, 10000, 500000, 1000000].each do |value|
			it "when specified, rythm should be numerical and greater than 0 (#{value} is valid)" do
				rec = Factory.build(:recording, :rythm=>value)
				rec.valid?.should == true
			end		
		end
	end
end
