require 'spec_helper'

describe Recording do

	describe "Testing for required values" do 
		[:recording_date, :recording_location, :rythm, :duration, :sample_rate].each {|field|	
			it "#{field} should allow nil" do 
				rec = Factory.build(:recording, field =>  nil)			
				rec.valid?.should be_true
			end
		}
	
		[].each {|field|	
			it "#{field} should not allow nil" do 
				rec = Factory.build(:recording, field =>  nil)			
				rec.valid?.should be_false
				rec.errors[field].include?("can't be blank").should == true
			end
		}
	end
	
	describe "Testing for the duration" do	
		["a", -15, 0].each {|value|
			it "when specified, duration should be numerical and greater than 0 (#{value} is not valid)" do
				rec = Factory.build(:recording, :duration=>value)
				rec.valid?.should be_false
			end
		}
	
		[1, 15, 300, 10000, 500000, 1000000].each {|value|
			it "when specified, duration should be numerical and greater than 0 (#{value} is valid)" do
				rec = Factory.build(:recording, :duration=>value)
				rec.valid?.should be_true
			end		
		}
	end
	
	describe "Testing for the rythm" do	
		["a", -15, 0].each {|value|
			it "when specified, rythm should be numerical and greater than 0 (#{value} is not valid)" do
				rec = Factory.build(:recording, :rythm=>value)
				rec.valid?.should be_false
			end
		}
	
		[1, 15, 300, 10000, 500000, 1000000].each {|value|
			it "when specified, rythm should be numerical and greater than 0 (#{value} is valid)" do
				rec = Factory.build(:recording, :rythm=>value)
				rec.valid?.should be_true
			end
		}
	end
	
	describe "Testing for the sample_rate" do
		["a", -15, 0].each {|value|
			it "when specified, sample_rate should be numerical and greater than 0 (#{value} is invalid)" do
				rec = Factory.build(:recording, :sample_rate=>value)
				rec.valid?.should be_false
			end		
		}
		# TODO : Insert commonly-used sample rates here
		[1, 15, 300, 10000, 500000, 1000000].each {|value|
			it "when specified, sample_rate should be numerical and greater than 0 (#{value} is valid)" do
				rec = Factory.build(:recording, :sample_rate=>value)
				rec.valid?.should be_true
			end
		}
	end
	
	describe "Testing for name" do
		[""].each {|value|
			it "when specified, name should be a non-empty string of alphanumeric characters and symbols (#{value} is invalid)" do
				rec = Factory.build(:recording, :work_title=>value)
				rec.valid?.should be_false
			end
		}
		# TODO : Complete this list
		#			+ How can I test for accentuated characters? They always crash the script with "invalid multibyte char"
		[	"A",
			"a",
			"Ab",
			"1",
			"Alpha123",
			"with spaces",
			"With 2 spaces",
			":",
			",",
			".",
			"'",
			"\"",
			"!",
			"@",
			"#",
			"%",
			"?",
			"&",
			"(",
			")"].each {|value|
			it "when specified, work_title should be a non-empty string of alphanumeric characters and symbols (#{value} is valid)" do
				rec = Factory.build(:recording, :work_title=>value)
				rec.valid?.should be_true
			end
		}
	end
	
	describe "Testing the recording date" do
	  it "for proper deserialization" do
	    rec = Factory.build(:recording, :duration => 127, :recording_date => "2007-05-30")
	    rec.valid?.should be_true
	    rec.save
	    
	    ctr = Recording.where(:duration => 127).first
	    ctr.recording_date.should be_kind_of(IncDate)
	  end
	end
end
