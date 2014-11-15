require 'spec_helper'

describe RecordingReleaseWikiLink do
  it { should have_field(:relation).of_type(String) }
end