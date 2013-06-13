require 'spec_helper'

describe Work do
  it { should embed_many(:tags) }
  it { should have_many(:user_tags) }
  it "should null out some wiki links that are attached to it when destroyed" do
    work = FactoryGirl.create(:work)
    attr_string = ""
    WorkWikiLink::SearchQuery::QUERY_ATTRS.keys.each do |attri| 
      attr_string += "#{attri}: \"#{attri}\" "
      work.should_receive(attri).at_least(1).and_return attri
    end
    wiki_link = Object.new
    klasses = [Artist, Recording, Work]
    klasses_size = klasses.size
    wiki_link.stub(:work_id).and_return work.id
    wiki_link.should_receive(:work_id=).with(nil).at_least klasses_size
    wiki_link.should_receive(:reference_text=).with(attr_string).at_least klasses_size
    wiki_link.should_receive(:save!).at_least klasses_size
    record = Object.new
    record.should_receive(:work_wiki_links).at_least(1).and_return [wiki_link]
    klasses.each do |klass|
      klass.should_receive(:where).at_least(1).with("work_wiki_links.work_id" => work.id).and_return klass
      klass.should_receive(:all).at_least(1).and_return [record]
    end
    work.destroy
  end
  it "should return a UserTagsWorker" do
    subject.user_tags_text.should be_a UserTagsWorker
  end
  it "should return its tokenized labels according to the user" do
    user = User.new
    tag = UserTag.new
    name = "test"
    tag.stub(:name).and_return name
    subject.should_receive(:user_tags).and_return subject
    subject.should_receive(:where).with(user:user).and_return [tag]
    subject.tokenized_user_tags(user).should eq [{id:name,name:name}].to_json
  end
end
