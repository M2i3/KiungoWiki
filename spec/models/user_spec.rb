require 'spec_helper'

describe User do
  it { should have_many(:possessions).with_foreign_key(:owner_id).with_dependent :destroy }
  it { should have_many(:labels).with_dependent :destroy }
  it { should have_many(:user_tags).with_dependent :destroy }
end
