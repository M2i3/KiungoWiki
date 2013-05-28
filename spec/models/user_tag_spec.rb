require 'spec_helper'

describe UserTag do
  it { should belong_to(:user) }
  it { should have_field(:name).of_type String }
  [:user, :name].each do |field|
    it { should validate_presence_of field }
  end
end