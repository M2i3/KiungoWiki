require 'spec_helper'

describe ArtistSearchQuery do
  it "should all go under the title when doing a basic query" do
    wsq = ArtistSearchQuery.new('This is a search " query with no keyworkds"')
    wsq[:name].should eql('This is a search " query with no keyworkds"')
    wsq[:birth_date].should eql(nil)
    wsq[:birth_location].should eql(nil)
    wsq[:death_date].should eql(nil)
    wsq[:death_location].should eql(nil)
    wsq[:oid].should eql(nil)
  end

  it "should set all the attributes in a complete query using what's left for the title" do
    wsq = ArtistSearchQuery.new('birth_date:1977-02-26 birth_location:"Sorel, QC, Canada" death_date:2075-03-17 death_location:"3rd satellite of saturn" Francois "Fantastic" Gaudreault oid:4e81265241c25e24b6340001')
    wsq[:name].should eql('Francois "Fantastic" Gaudreault')
    wsq[:birth_date].should eql("1977-02-26")
    wsq[:birth_location].should eql("Sorel, QC, Canada")
    wsq[:death_date].should eql("2075-03-17")
    wsq[:death_location].should eql("3rd satellite of saturn")
    wsq[:oid].should eql("4e81265241c25e24b6340001")
  end
end
