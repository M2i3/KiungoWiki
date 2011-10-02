class AlbumWikiLink
  include Mongoid::Document

  field :reference
  field :title
  referenced_in :album
  embedded_in :linkable, :polymorphic => true

  def album=(value)
    if value
      self.album_id = value.id
      self.title = value.title
    else   
      self.title = nil
      self.album_id = nil
    end
  end

  def encoded_link
    self.title
  end
  
  def encoded_link=(value)
    self.reference = value
    asq = AlbumSearchQuery.new(value)
    if asq[:oid]
      self.album = Album.find(asq[:oid]) 
    else
      self.album = nil
      self.title = self.reference
    end
  end

  def combined_link
    if self.title || self.album_id 
      {id: self.encoded_link, name: self.title.to_s}
    end
  end 
end
