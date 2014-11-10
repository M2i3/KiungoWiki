require 'spec_helper'

describe Publisher do
  it { should have_field(:name).of_type(String) }
  it { should validate_presence_of(:name) }
  it { should have_field(:count).of_type(Integer).with_default_value_of(0) }
end