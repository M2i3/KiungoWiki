class AlbumWikiLink
  include Mongoid::Document
  include WikiLink

  set_reference_class Album, AlbumSearchQuery

  def trackNb
    searchref[:trackNb]
  end

  def itemId
    searchref[:itemId]
  end

  def itemSection
    searchref[:itemSection]
  end

  def title
    (album && self.album.title) || self.objectq
  end
  
  def date_released
    (self.album && self.album.date_released) || ""
  end

  def label
    (self.album && self.album.label) || ""
  end

  def media_type
    (self.album && self.album.media_type) || ""
  end

  def reference_code
    (self.album && self.album.reference_code) || ""
  end

  def object_text
    self.title
  end
end






