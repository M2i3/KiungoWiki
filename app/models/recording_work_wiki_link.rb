class RecordingWorkWikiLink < WorkWikiLink
  include Mongoid::Document

  class SearchQuery < self.superclass::SearchQuery 
  end
end


