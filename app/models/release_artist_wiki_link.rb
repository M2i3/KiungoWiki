class ReleaseArtistWikiLink < ArtistWikiLink
  include Mongoid::Document

  define_signed_as Release, :artist_wiki_links
  
  class SearchQuery < self.superclass::SearchQuery 
  end
end


