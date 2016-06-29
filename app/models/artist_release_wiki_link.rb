class ArtistReleaseWikiLink < ReleaseWikiLink
  include Mongoid::Document
  
  define_signed_as Artist, :release_wiki_links

  class SearchQuery < self.superclass::SearchQuery 
  end
end


