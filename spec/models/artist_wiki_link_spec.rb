require 'spec_helper'

describe ArtistWikiLink do
  it { should have_field(:start_date).of_type(String) }
  it { should have_field(:end_date).of_type(String) }
end
