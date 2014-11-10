require 'spec_helper'

describe ReleaseWikiLink do
  it { should have_field(:item_section).of_type(String) }
  it { should have_field(:item_id).of_type(String) }
  it { should have_field(:track_number).of_type(String) }
end
