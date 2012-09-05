class RecordingWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Recording, RecordingSearchQuery
  cache_attributes :title, :recording_date, :duration

  def title_with_objectq
    title_without_objectq.blank? ? self.objectq : title_without_objectq
  end
  alias_method_chain :title, :objectq

  def trackNb
    searchref[:trackNb]
  end

  def itemId
    searchref[:itemId]
  end

  def itemSection
    searchref[:itemSection]
  end

  def object_text
    self.title.to_s 
  end
end

