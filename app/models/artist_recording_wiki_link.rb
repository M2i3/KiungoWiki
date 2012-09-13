class ArtistRecordingWikiLink < RecordingWikiLink
  include Mongoid::Document

  def role
    searchref[:role]
  end

  class SearchQuery < RecordingWikiLink::SearchQuery 
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


