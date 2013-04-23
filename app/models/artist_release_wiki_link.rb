class ArtistReleaseWikiLink < ReleaseWikiLink
  include Mongoid::Document

  class SearchQuery < self.superclass::SearchQuery 
  end
end


