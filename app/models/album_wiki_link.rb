class AlbumWikiLink
  include Mongoid::Document

  field :reference
  field :title
  referenced_in :album
  embedded_in :linkable, :polymorphic => true

  def reference_text
    self.reference
  end
  
  def reference_text=(value)
    self.reference = value
    asq = AlbumSearchQuery.new(value)
    if asq[:oid]
      self.album = Album.find(asq[:oid]) 
      self.title = self.album.title
    else
      self.album = nil
      self.title = self.reference
    end
  end

  def combined_link
    if self.reference_text || self.title 
      {id: self.reference_text, title: self.title.to_s}
    end
  end 
end






