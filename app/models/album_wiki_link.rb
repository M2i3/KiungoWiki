class AlbumWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Album, AlbumSearchQuery
  cache_attributes :title, :label, :date_released

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
    GroupText.new([
        self.title.to_s,
        GroupText.new([
            GroupText.new([
                 self.date_released], 
                 :before_text=>"(", :after_text=>")"), 
            self.album && self.album.first_artist_display_text],
            :sep=>" - ")],
        :sep=>" - ").to_s
  end
end






