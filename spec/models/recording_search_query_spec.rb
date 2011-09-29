require 'spec_helper'

describe RecordingSearchQuery do
  it "should all go under the title when doing a basic query" do
    wsq = RecordingSearchQuery.new('This is a search " query with no keyworkds"')
    wsq[:title].should eql('This is a search " query with no keyworkds"')
    wsq[:recording_date].should eql(nil)
    wsq[:recording_location].should eql(nil)
    wsq[:rythm].should eql(nil)
    wsq[:oid].should eql(nil)
  end

  it "should set all the attributes in a complete query using what's left for the title" do
    wsq = RecordingSearchQuery.new('recording_date:2011-09-01 This is a search " query with no keyworkds" recording_location:"Montreal" oid:4e81265241c25e24b6000001 rythm:120')
    wsq[:title].should eql('This is a search " query with no keyworkds"')
    wsq[:recording_date].should eql("2011-09-01")
    wsq[:recording_location].should eql("Montreal")
    wsq[:rythm].should eql("120")
    wsq[:oid].should eql("4e81265241c25e24b6000001")
  end
end
