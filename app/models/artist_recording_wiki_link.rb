class ArtistRecordingWikiLink < RecordingWikiLink
  include Mongoid::Document

  define_signed_as Artist, :recording_wiki_links
  
  def role
    searchref[:role]
  end

  class SearchQuery < self.superclass::SearchQuery 
    def self.query_expressions
      super.merge({ 
        role: :text
      })
    end
    def self.meta_fields
      super + [:role]
    end
  end
end


