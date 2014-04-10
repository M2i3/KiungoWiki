require 'spec_helper'

describe RecordingWikiLink do
  it { should have_field(:role).of_type(String) }
end
