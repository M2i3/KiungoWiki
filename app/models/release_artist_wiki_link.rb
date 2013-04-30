class ReleaseArtistWikiLink < ArtistWikiLink
  include Mongoid::Document

  class SearchQuery < self.superclass::SearchQuery 
  end
end


