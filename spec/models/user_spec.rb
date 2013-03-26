require 'spec_helper'

describe User do
  it { should have_many(:possessions).with_foreign_key(:owner_id) }
  it { should have_many(:labels) }
end
