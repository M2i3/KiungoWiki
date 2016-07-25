class ArtistArtistWikiLink < ArtistWikiLink
  include Mongoid::Document
  
  wiki_link_additional_field :start_date, type: IncDate
  wiki_link_additional_field :end_date, type: IncDate

  define_signed_as Artist, :artist_wiki_links

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

