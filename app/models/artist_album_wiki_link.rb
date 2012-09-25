class ArtistAlbumWikiLink < AlbumWikiLink
  include Mongoid::Document

  class SearchQuery < self.superclass::SearchQuery 
  end
end


