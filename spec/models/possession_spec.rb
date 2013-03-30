require 'spec_helper'

describe Possession do
  it { should belong_to(:owner).of_type(User).with_index }
  it { should belong_to(:album).with_index }
  it { should validate_uniqueness_of(:album).scoped_to(:owner) }
  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:album) }
  it { should have_field(:labels).of_type(Array).with_default_value_of [] }
  it { should have_field(:rating).of_type(Integer) }
  it { should have_field(:acquisition_date).of_type(Date) }
  it { should have_field(:comments).of_type(String) }
  it "should try to create some user labels after it's been saved" do
    label = "label"
    user = FactoryGirl.create(:user)
    album = FactoryGirl.create(:album)
    Possession.where(owner:user, labels:[label], album:album).create!
    Possession.where(owner:user, album:album).all.size.should eq 1
    Label.all.size.should eq 1
  end
  it "should be able to tokenize labels" do
    subject.labels = ["label1", "label2"]
    subject.tokenized_labels.should eq [{id:"label1", name:"label1"},{id:"label2", name:"label2"}].to_json
  end
end
