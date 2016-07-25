class WorkArtistWikiLink < ArtistWikiLink
  include Mongoid::Document
  
  wiki_link_additional_field :role, type:String
  
  define_signed_as Work, :artist_wiki_links
  
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


