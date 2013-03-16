require 'spec_helper'

describe AlbumWikiLink::SearchQuery do
  it "should all go under the title when doing a basic query" do
    wsq = AlbumWikiLink::SearchQuery.new('This is a search " query with no keyworkds"')
    wsq[:title].should eql('This is a search " query with no keyworkds"')
    wsq[:media_type].should eql(nil)
    wsq[:label].should eql(nil)
    wsq[:reference_code].should eql(nil)
    wsq[:oid].should eql(nil)
  end

  it "should set all the attributes in a complete query using what's left for the title" do
    wsq = AlbumWikiLink::SearchQuery.new('date_released:2011-09-01 This is a search " query with no keyworkds" label:"Production Pierre F." oid:4e81265241c25e24b6000001 reference_code:"425345lkj-1234"')
    wsq[:title].should eql('This is a search " query with no keyworkds"')
    wsq[:date_released].should eql("2011-09-01")
    wsq[:label].should eql("Production Pierre F.")
    wsq[:reference_code].should eql("425345lkj-1234")
    wsq[:oid].should eql("4e81265241c25e24b6000001")
  end
end


