class ArtistWikiLink
  include Mongoid::Document

  field :reference
  field :name
  referenced_in :artist
  embedded_in :linkable, :polymorphic => true

  def reference_text
    self.reference
  end
  
  def reference_text=(value)
    self.reference = value
    asq = ArtistSearchQuery.new(value)
    if asq[:oid]
      self.artist = Artist.find(asq[:oid]) 
      self.name = self.artist.name
    else
      self.artist = nil
      self.name = self.reference
    end
  end

  def combined_link
    if self.reference_text || self.name
      {id: self.reference_text, name: self.name.to_s}
    end
  end 
end
