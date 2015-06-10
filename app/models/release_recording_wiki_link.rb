class ReleaseRecordingWikiLink < RecordingWikiLink
  include Mongoid::Document
  field :itemSection, type: String
  field :itemId, type: String
  field :trackNb, type: String

  class SearchQuery < self.superclass::SearchQuery 
    def self.query_expressions
      super.merge({ 
        trackNb: :numeric,
        itemId: :word,
        itemSection: :character      
      })
    end
    def self.meta_fields
      super + [:trackNb, :itemId, :itemSection]
    end
  end
end


