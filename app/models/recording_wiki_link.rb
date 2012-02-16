class RecordingWikiLink
  include Mongoid::Document

  field :reference
  field :title
  field :trackNb
  field :itemId
  field :itemSection
  referenced_in :recording
  embedded_in :linkable, :polymorphic => true

  def reference_text
    self.reference
  end
  
  def reference_text=(value)
    self.reference = value
    rsq = RecordingSearchQuery.new(value)
    if rsq[:oid]
      self.recording = Recording.find(rsq[:oid]) 
      self.title = self.recording.title
      if ![nil,""].include?(self.recording.title)
        self.title = self.recording.title
      end
    else
      self.recording = nil
      self.title = self.reference
    end
  end

  def combined_link
    if self.reference_text || self.title
      {id: self.reference_text, title: self.title.to_s}
    end
  end 
end
