require 'spec_helper'

describe Recording do
  it { should embed_many(:tags) }
  it { should have_many(:user_tags) }
	describe "Testing for required values" do 
		[:recording_date, :recording_location, :rythm, :duration].each {|field|	
			it "#{field} should allow nil" do 
				rec = FactoryGirl.build(:recording, field =>  nil)			
				rec.valid?.should be_true
			end
		}
	
		[].each {|field|	
			it "#{field} should not allow nil" do 
				rec = FactoryGirl.build(:recording, field =>  nil)			
				rec.valid?.should be_false
				rec.errors[field].include?("can't be blank").should == true
			end
		}
	end

	describe "Testing for the duration" do	
		["a", -15, 0].each {|value|
			it "when specified, duration should be numerical and greater than 0 (#{value} is not valid)" do
				rec = FactoryGirl.build(:recording, :duration_text=>value)
				rec.valid?.should be_false
			end
		}
	
		[1, 15, 300, 10000, 500000, 1000000, "23:32", "50432:23:21", "1:90", "12"].each {|value|
			it "when specified, duration should be numerical and greater than 0 (#{value} is valid)" do
				rec = FactoryGirl.build(:recording, :duration_text=>value)
				rec.valid?.should be_true
			end		
		}
	end
	
	describe "Testing for the rythm" do	
		["a", -15, 0].each {|value|
			it "when specified, rythm should be numerical and greater than 0 (#{value} is not valid)" do
				rec = FactoryGirl.build(:recording, :rythm_text=>value)
				rec.valid?.should be_false
			end
		}
	
		[1, 15, 300, 10000, 500000, 1000000].each {|value|
			it "when specified, rythm should be numerical and greater than 0 (#{value} is valid)" do
				rec = FactoryGirl.build(:recording, :rythm_text=>value)
				rec.valid?.should be_true
			end
		}
	end
	

  describe "Testing the links to the artists" do
    
  end

  if false # TODO this test needs reviewing considering the recording is a link on the work and does not have a title by itself.	
	  describe "Testing for name" do

		  [""].each {|value|
			  it "when specified, name should be a non-empty string of alphanumeric characters and symbols (#{value} is invalid)" do
				  rec = FactoryGirl.create(:recording, :work_title=>value)
				  rec.valid?.should be_false
			  end
		  }
		  # TODO : Complete this list
		  #			+ How can I test for accentuated characters? They always crash the script with "invalid multibyte char"
      YAML.load_file("spec/factories/multi.yml")["multibytestrings"] + 
		  [	"A",
			  "a",
			  "Ab",
			  "1",
			  "Alpha123",
			  "with spaces",
			  "With 2 spaces",
			  ":",
			  ",",
			  ".",
			  "'",
			  "\"",
			  "!",
			  "@",
			  "#",
			  "%",
			  "?",
			  "&",
			  "(",
			  ")"].each {|value|
			  it "when specified, work_title should be a non-empty string of alphanumeric characters and symbols (#{value} is valid)" do
				  rec = FactoryGirl.create(:recording, :work_title=>value)
				  rec.valid?.should be_true
			  end
		  }
	  end
  end
	
	describe "Testing the recording date" do
	  it "for proper deserialization" do
	    rec = FactoryGirl.create(:recording, :duration => 127, :recording_date => "2007-05-30")
	    rec.valid?.should be_true
	    rec.save
	    
	    ctr = Recording.where(:duration => 127).first
	    ctr.recording_date.should be_kind_of(IncDate)
	  end
	end
  it "should null out some wiki links that are attached to it when destroyed" do
    recording = FactoryGirl.create(:recording)
    attr_string = ""
    RecordingWikiLink::SearchQuery::QUERY_ATTRS.keys.each do |attri| 
      attr_string += "#{attri}: \"#{attri}\" "
      recording.should_receive(attri).at_least(1).and_return attri
    end
    wiki_link = Object.new
    klasses = [Artist, Release, Work]
    klasses_size = klasses.size
    wiki_link.stub(:recording_id).and_return recording.id
    wiki_link.should_receive(:recording_id=).with(nil).at_least klasses_size
    wiki_link.should_receive(:reference_text=).with(attr_string).at_least klasses_size
    wiki_link.should_receive(:save!).at_least klasses_size
    record = Object.new
    record.should_receive(:recording_wiki_links).at_least(1).and_return [wiki_link]
    klasses.each do |klass|
      klass.should_receive(:where).at_least(1).with("recording_wiki_links.recording_id" => recording.id).and_return klass
      klass.should_receive(:all).at_least(1).and_return [record]
    end
    recording.destroy
  end
  it "should return a UserTagsWorker" do
    subject.user_tags_text.should be_a UserTagsWorker
  end
  it "should return its tokenized labels according to the user" do
    user = User.new
    tag = UserTag.new
    name = "test"
    tag.stub(:name).and_return name
    subject.should_receive(:user_tags).and_return subject
    subject.should_receive(:where).with(user:user).and_return [tag]
    subject.tokenized_user_tags(user).should eq [{id:name,name:name}].to_json
  end
end
