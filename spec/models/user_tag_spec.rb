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
end