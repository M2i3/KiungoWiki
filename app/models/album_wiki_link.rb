class AlbumWikiLink
  include Mongoid::Document

  field :reference_text
  referenced_in :album
  embedded_in :linkable, :polymorphic => true
  
  def reference_text=(value)
    self[:reference_text] = value
    asq = AlbumSearchQuery.new(value)
    if asq[:oid]
      self.album = Album.find(asq[:oid]) 
    else
      self.album = nil
    end
  end

  def searchref
    AlbumSearchQuery.new(self.reference_text)
  end

  def title
    if album
      self.album.title
    else
      self.reference_text
    end
  end
  
  def date_released
    self.album.date_released if self.album
  end

  def label
    self.album.label if self.album
  end

  def media_type
    self.album.media_type if self.album
  end

  def reference_code
    self.album.reference_code if self.album
  end

  def combined_link
    if self.reference_text || self.title 
      {id: self.reference_text, title: self.title.to_s}
    end
  end 
end






