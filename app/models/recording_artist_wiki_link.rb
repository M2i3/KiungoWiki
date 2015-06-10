class RecordingArtistWikiLink < ArtistWikiLink
  include Mongoid::Document
  
  field :role, type:String

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


