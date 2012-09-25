class ArtistArtistWikiLink < ArtistWikiLink
  include Mongoid::Document

  def relation
    searchref[:relation]
  end

  class SearchQuery < ArtistWikiLink::SearchQuery 
    def self.query_expressions
      super.merge({ 
        relation: :text
      })
    end
    def self.meta_fields
      super + [:relation]
    end
  end
end

