class RecordingWikiLink
  include Mongoid::Document
  include WikiLink

  set_reference_class Recording, RecordingSearchQuery

  def title
    (recording && self.recording.title) || self.objectq
  end

  def trackNb
    searchref[:trackNb]
  end

  def itemId
    searchref[:itemId]
  end

  def itemSection
    searchref[:itemSection]
  end

  def recording_date
     (self.recording && self.recording.recording_date) || ""
  end

  def duration
     (self.recording && self.recording.duration) || ""
  end

  def object_text
    self.title.to_s 
  end
end

