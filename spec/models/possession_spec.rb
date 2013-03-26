require 'spec_helper'

describe Possession do
  it { should belong_to(:owner).of_type(User).with_index }
  it { should belong_to(:album).with_index }
  it { should validate_uniqueness_of(:album).scoped_to(:owner) }
  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:album) }
  it { should have_field(:labels).of_type(Array) }
end
