require 'spec_helper'

describe Label do
  it { should belong_to(:user).with_index }
  it { should validate_presence_of(:name) }
  it { should have_field(:count).of_type(Integer) }
end
