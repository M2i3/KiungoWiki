require 'spec_helper'

describe Category do
  it { should have_field(:cache_normalized_name).of_type(String).with_default_value_of '' }
  it { should have_index_for(cache_normalized_name: 1).with_options background:true }
  context 'with an accented name' do
    before :each do
      @category = Category.new category_name:'Élie Rose'
    end
    it 'should remove accents from the normalized title' do
      expect(@category.normalized_name).to eq 'elierose'
    end
    it 'should save a normalized_name when it\'s cached' do
      @category.save! validate:false
      expect(@category.cache_normalized_name).to eq @category.normalized_name
    end
  end
end
