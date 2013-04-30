require 'spec_helper'

describe Release do
  it { should have_many(:possessions) }
end
