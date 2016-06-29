class WorkRecordingWikiLink < RecordingWikiLink
  include Mongoid::Document
  
  define_signed_as Work, :recording_wiki_links

  class SearchQuery < self.superclass::SearchQuery 
  end
end


