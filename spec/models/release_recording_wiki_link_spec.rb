require 'spec_helper'

describe ReleaseRecordingWikiLink do
  
  it { should have_field(:itemSection).of_type(String) }
  it { should have_field(:itemId).of_type(String) }
  it { should have_field(:trackNb).of_type(String) }
end