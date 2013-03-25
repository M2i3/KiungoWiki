require 'spec_helper'

describe Label do
  it { should belong_to(:user).with_index }
  it { should belong_to(:possession) }
  it { should validate_presence_of(:name) }
end
