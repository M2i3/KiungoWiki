require 'spec_helper'

describe Possession do
  it { should belong_to(:owner).of_type(User).with_index }
  it { should belong_to(:album).with_index }
  it { should validate_uniqueness_of(:album).scoped_to(:owner) }
  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:album) }
  it { should have_field(:labels).of_type(Array) }
  it "should try to create some user labels after it's been saved" do
    label = "label"
    user = FactoryGirl.create(:user)
    Label.should_receive(:find_or_create_by).at_least(1).with(name:label,user:user)
    album = FactoryGirl.create(:album)
    Possession.where(owner:user, labels:[label], album:album).create!
  end
  it "should be able to tokenize labels" do
    subject.labels = ["label1", "label2"]
    subject.tokenized_labels.should eq [{id:"label1", name:"label1"},{id:"label2", name:"label2"}].to_json
  end
end
