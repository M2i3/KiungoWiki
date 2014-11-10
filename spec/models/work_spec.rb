require 'spec_helper'

describe Work do
  it { should embed_many(:tags) }
  it { should have_many(:user_tags) }
  it { should have_field(:missing_tags).of_type Boolean }
  it { should have_field(:missing_supplementary_sections).of_type Boolean }
  it { should have_field(:publishers).of_type(Array).with_default_value_of [] }
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
  it 'should remove accents from the normalized title' do
    work = Work.new title:'Élie Rose'
    expect(work.normalized_title).to eq 'elierose'
  end
  it "should try to create some user labels after it's been saved" do
    publisher = "publiser"
    work = FactoryGirl.create(:work, publishers:[publisher])
    expect(Publisher.all.size).to eq 1
    pub = Publisher.first
    expect(pub.name).to eq publisher
  end
  it "should be able to tokenize publishers" do
    subject.publishers = ["publiser1", "publiser2"]
    subject.tokenized_publishers.should eq [{id:"publiser1", name:"publiser1"},{id:"publiser2", name:"publiser2"}].to_json
  end
  it "should be able to set and retreive labels_text" do
    publishers = ["publiser1", "publiser2"]
    subject.publishers = publishers
    subject.publishers_text.should eq publishers.join(", ")
  end
end
