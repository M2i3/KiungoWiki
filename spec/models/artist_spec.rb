require 'spec_helper'

describe Artist do
  it "should null out some wiki links that are attached to it" do
    artist = FactoryGirl.create(:artist)
    attr_string = ""
    ArtistWikiLink::SearchQuery::QUERY_ATTRS.keys.each do |attri| 
      attr_string += "#{attri}: \"#{attri}\" "
      artist.should_receive(attri).at_least(1).and_return attri
    end
    wiki_link = Object.new
    klasses = [Artist, Recording, Release, Work]
    klasses_size = klasses.size
    wiki_link.stub(:artist_id).and_return artist.id
    wiki_link.should_receive(:artist_id=).with(nil).at_least klasses_size
    wiki_link.should_receive(:reference_text=).with(attr_string).at_least klasses_size
    wiki_link.should_receive(:save!).at_least klasses_size
    record = Object.new
    record.should_receive(:artist_wiki_links).at_least(1).and_return [wiki_link]
    klasses.each do |klass|
      klass.should_receive(:where).at_least(1).with("artist_wiki_links.artist_id" => artist.id).and_return klass
      klass.should_receive(:all).at_least(1).and_return [record]
    end
    artist.destroy
  end
end
