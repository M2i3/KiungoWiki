class RecordingWikiLink
  include Mongoid::Document

  field :reference_text
  referenced_in :recording
  embedded_in :linkable, :polymorphic => true

  def reference_text=(value)
    self[:reference_text] = value
    rsq = RecordingSearchQuery.new(value)
    if rsq[:oid]
      self.recording = Recording.find(rsq[:oid]) 
    else
      self.recording = nil
    end
  end

  def searchref
    RecordingSearchQuery.new(self.reference_text)
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

  def title
    if recording
      self.recording.title
    else
      self.reference_text
    end 
  end

  def recording_date
     self.recording.recording_date if self.recording
  end

  def duration
     self.recording.duration if self.recording
  end

  def combined_link
    if self.reference_text || self.title
      {id: self.reference_text, title: self.title.to_s}
    end
  end 
end