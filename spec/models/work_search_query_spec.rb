require 'spec_helper'

describe WorkSearchQuery do
  it "should all go under the title when doing a basic query" do
    wsq = WorkSearchQuery.new('This is a search " query with no keyworkds"')
    wsq[:title].should eql('This is a search " query with no keyworkds"')
    wsq[:copyright].should eql(nil)
    wsq[:date_written].should eql(nil)
    wsq[:language_code].should eql(nil)
    wsq[:oid].should eql(nil)
    wsq[:publisher].should eql(nil)
    wsq[:origworkid].should eql(nil)

  end

  it "should set all the attributes in a complete query using what's left for the title" do
    wsq = WorkSearchQuery.new('copyright:"1994, Jean-Marc" date_written:2011-09-01 This is a search " query with no keyworkds" language_code:fr oid:4e81265241c25e24b6000001 publisher:"Pierre F." origworkid:123212')
    wsq[:title].should eql('This is a search " query with no keyworkds"')
    wsq[:copyright].should eql("1994, Jean-Marc")
    wsq[:date_written].should eql("2011-09-01")
    wsq[:language_code].should eql("fr")
    wsq[:oid].should eql("4e81265241c25e24b6000001")
    wsq[:publisher].should eql("Pierre F.")
    wsq[:origworkid].should eql("123212")
  end
end
