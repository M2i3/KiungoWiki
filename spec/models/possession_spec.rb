require 'spec_helper'

describe Possession do
  it { should belong_to(:owner).of_type(User).with_index }
  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:release_wiki_link) }
  it { should embed_one(:release_wiki_link) }
  it { should validate_associated(:release_wiki_link) }
  it { should accept_nested_attributes_for(:release_wiki_link) }
  it { should have_field(:labels).of_type(Array).with_default_value_of [] }
  it { should have_field(:rating).of_type(Integer).with_default_value_of 0 }
  it { should have_field(:acquisition_date).of_type(Date) }
  it { should have_field(:comments).of_type(String) }
  it "should try to create some user labels after it's been saved" do
    label = "label"
    user = FactoryGirl.create(:user)
    release = ReleaseWikiLink.new
    Possession.where(owner:user, labels:[label], release_wiki_link:release).create!
    Possession.where(owner:user).all.size.should eq 1
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
  it "should be able to set and retreive labels_text" do
    labels = ['label1', 'label2']
    subject.labels_text = labels.join ","
    subject.labels_text.should eq labels.join(", ")
    subject.labels.should eq labels
  end
  it "should be able to construct release_wiki_link with an external attribute" do
    ref = "title: Blondie"
    subject.release_wiki_link_text = ref
    subject.release_wiki_link.should be_a ReleaseWikiLink
    subject.release_wiki_link.reference_text.should eq ref
    subject.release_wiki_link_text.should eq ref
  end
end
