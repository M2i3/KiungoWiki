require 'spec_helper'

describe UserTag do
  it { should belong_to(:user) }
  it { should have_field(:name).of_type String }
  [:user, :name].each do |field|
    it { should validate_presence_of field }
  end
  it { should belong_to :taggable }
  it "should be able to retrieve its taggable" do
    id = 99
    artist = Artist.new
    subject.taggable = artist
    subject.taggable_id = id
    Artist.should_receive(:find).with(id).and_return artist
    subject.taggable.should eq artist
  end
  # it "should be able to search and create a public tag inside of the resource if it's at or above the threshold" do
  #   artist = FactoryGirl.create(:artist)
  #   user = FactoryGirl.create(:user)
  #   name = "test"
  #   subject.taggable = artist
  #   subject.name = name
  #   subject.user = user
  #   # .with(name: /#{name}/i, taggable_type: artist.class.to_s, taggable_id:artist.id).
  #   UserTag.should_receive(:where).at_least(1).and_return UserTag
  #   UserTag.should_receive(:size).at_least(1).and_return (ENV["TAG_COUNT"].to_i - 1)
  #   subject.save!
  #   artist.reload.tags.size.should eq 1
  # end
end