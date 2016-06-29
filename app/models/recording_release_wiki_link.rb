class RecordingReleaseWikiLink < ReleaseWikiLink
  include Mongoid::Document
  field :itemSection, type: String
  field :itemId, type: String
  field :trackNb, type: String

  define_signed_as Recording, :release_wiki_links

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


