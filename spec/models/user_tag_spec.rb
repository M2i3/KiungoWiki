require 'spec_helper'

describe UserTag do
  it { should belong_to(:user) }
  it { should have_field(:name).of_type String }
  it { should have_field(:cache_normalized_name).of_type(String).with_default_value_of '' }
  [:user, :name].each do |field|
    it { should validate_presence_of field }
  end
  it { should have_index_for(cache_normalized_name: 1).with_options background:true }
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
  context 'with an accented name' do
    before :each do
      @tag = UserTag.new name:'Élie Rose'
    end
    it 'should remove accents from the normalized title' do
      expect(@tag.normalized_name).to eq 'elierose'
    end
    it 'should save a normalized_name when it\'s cached' do
      @tag.user = FactoryGirl.create(:user)
      @tag.taggable = FactoryGirl.create(:artist)
      @tag.save! validate:false
      expect(@tag.cache_normalized_name).to eq @tag.normalized_name
    end
  end
end
