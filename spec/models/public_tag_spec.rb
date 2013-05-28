require 'spec_helper'

describe PublicTag do
  it { should have_field(:name).of_type String }
  it { should have_field(:size).of_type Integer }
  [:name, :size].each do |field|
    it { should validate_presence_of field }
  end
  it { should be_embedded_in(:taggable) }
end
