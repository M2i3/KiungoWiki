require 'spec_helper'

describe PublicTag do
  it { should have_field(:name).of_type String }
  it { should have_field(:size).of_type Integer }
  it { should have_field(:cache_normalized_name).of_type(String).with_default_value_of "" }
  it { should have_index_for(cache_normalized_name: 1).with_options background:true }
  [:name, :size].each do |field|
    it { should validate_presence_of field }
  end
  it { should be_embedded_in(:taggable) }
  context 'with an accented name' do
    before :each do
      @tag = PublicTag.new name:'Élie Rose'
    end
    it 'should remove accents from the normalized title' do
      expect(@tag.normalized_name).to eq 'elierose'
    end
    it 'should save a normalized_name when it\'s cached' do
      @tag.taggable = FactoryGirl.create(:artist)
      @tag.save! validate:false
      expect(@tag.cache_normalized_name).to eq @tag.normalized_name
    end
  end
end
