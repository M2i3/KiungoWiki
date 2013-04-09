require 'spec_helper'

describe Possession do
  it { should belong_to(:owner).of_type(User).with_index }
  it { should belong_to(:release).with_index }
  it { should validate_uniqueness_of(:release).scoped_to(:owner) }
  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:release) }
  it { should have_field(:labels).of_type(Array).with_default_value_of [] }
  it { should have_field(:rating).of_type(Integer).with_default_value_of 0 }
  it { should have_field(:acquisition_date).of_type(Date) }
  it { should have_field(:comments).of_type(String) }
  it "should try to create some user labels after it's been saved" do
    label = "label"
    user = FactoryGirl.create(:user)
    release = FactoryGirl.create(:release)
    Possession.where(owner:user, labels:[label], release:release).create!
    Possession.where(owner:user, release:release).all.size.should eq 1
    Label.all.size.should eq 1
    lab = Label.first
    lab.user.should eq user
    lab.name.should eq label
    # lab.count.should eq 1
  end
  it "should be able to tokenize labels" do
    subject.labels = ["label1", "label2"]
    subject.tokenized_labels.should eq [{id:"label1", name:"label1"},{id:"label2", name:"label2"}].to_json
  end
  it "should be able to set and give back an album given in wiki format" do
    id = "123"
    wiki_id = "oid:#{id} "
    subject.release_wiki = wiki_id
    subject.release_id.should eq id
    subject.release_wiki.should eq wiki_id.strip
  end
  it "should be able to set and retreive labels_text" do
    labels = ['label1', 'label2']
    subject.labels_text = labels.join ","
    subject.labels_text.should eq labels.join(", ")
    subject.labels.should eq labels
  end
end
