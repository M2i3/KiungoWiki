class WorkRecordingWikiLink < RecordingWikiLink
  include Mongoid::Document

  class SearchQuery < self.superclass::SearchQuery 
  end
end


