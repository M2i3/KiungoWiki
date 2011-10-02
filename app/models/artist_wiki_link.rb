class ArtistWikiLink
  include Mongoid::Document

  field :reference
  field :name
  referenced_in :artist
  embedded_in :linkable, :polymorphic => true

  def artist=(value)
    if value
      self.artist_id = value.id
      self.name = value.name
    else   
      self.name = nil
      self.artist_id = nil
    end
  end

  def encoded_link
    self.name
  end
  
  def encoded_link=(value)
    self.reference = value
    asq = ArtistSearchQuery.new(value)
    if asq[:oid]
      self.artist = Artist.find(asq[:oid]) 
    else
      self.artist = nil
      self.name = self.reference
    end
  end

  def combined_link
    if self.name || self.artist_id 
      {id: self.encoded_link, name: self.name.to_s}
    end
  end 
end
