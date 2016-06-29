class RecordingWorkWikiLink < WorkWikiLink
  include Mongoid::Document
  
  define_signed_as Recording, :work_wiki_link

  class SearchQuery < self.superclass::SearchQuery 
  end
end


