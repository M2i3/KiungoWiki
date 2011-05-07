require 'spec_helper'

describe Recording do
	subject do 
		Factory.build(:recording, :recording_date=>nil, :recording_location=>nil, :duration=>nil)
	end	
	it {
		subject.valid?
		subject.errors[:recording_date].empty?.should == true
		subject.errors[:recording_location].empty?.should == true
		subject.errors[:duration].empty?.should == false
	}

end
