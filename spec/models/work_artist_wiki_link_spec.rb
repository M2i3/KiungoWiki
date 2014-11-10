require 'spec_helper'

describe WorkArtistWikiLink do
  it { should have_field(:relation).of_type(String) }
end