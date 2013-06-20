require 'spec_helper'

describe UserTag do
  it { should belong_to(:user) }
  it { should have_field(:name).of_type String }
  [:user, :name].each do |field|
    it { should validate_presence_of field }
  end
  it { should belong_to :taggable }
  it "should be able to search and create a public tag inside of the resource if it's at or above the threshold" do
    artist = FactoryGirl.create(:artist)
    user = FactoryGirl.create(:user)
    name = "test"
    ENV.stub(:[]).with("TAG_COUNT").and_return 2
    subject.taggable = artist
    subject.name = name
    subject.user = user
    subject.save!
    artist.reload.tags.size.should eq 1
  end
end