require 'spec_helper'

describe Release do
  it { should embed_many(:tags) }
  it "should null out some wiki links that are attached to it when destroyed" do
    release = FactoryGirl.create(:release)
    attr_string = ""
    ReleaseWikiLink::SearchQuery::QUERY_ATTRS.keys.each do |attri| 
      attr_string += "#{attri}: \"#{attri}\" "
      release.should_receive(attri).at_least(1).and_return attri
    end
    wiki_link = Object.new
    klasses = [Artist, Recording]
    klasses_size = klasses.size
    wiki_link.stub(:release_id).and_return release.id
    wiki_link.should_receive(:release_id=).with(nil).at_least klasses_size
    wiki_link.should_receive(:reference_text=).with(attr_string).at_least klasses_size
    wiki_link.should_receive(:save!).at_least klasses_size
    record = Object.new
    record.should_receive(:release_wiki_links).at_least(1).and_return [wiki_link]
    klasses.each do |klass|
      klass.should_receive(:where).at_least(1).with("release_wiki_links.release_id" => release.id).and_return klass
      klass.should_receive(:all).at_least(1).and_return [record]
    end
    release.destroy
  end
end
