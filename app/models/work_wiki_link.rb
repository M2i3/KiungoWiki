class WorkWikiLink
  include Mongoid::Document

  field :reference_text
  referenced_in :work
  embedded_in :linkable, :polymorphic => true

  def reference_text=(value)
    self[:reference_text] = value
    wsq = WorkSearchQuery.new(value)
    if wsq[:oid]
      self.work = Work.find(wsq[:oid]) 
    else
      self.work = nil
    end
  end

  def searchref
    WorkSearchQuery.new(self.reference_text)
  end

  def title
    if work
      self.work.title
    else
      self.reference_text
    end
  end

  def combined_link
    if self.reference_text || self.title
      {id: self.reference_text, title: self.title.to_s}
    end
  end 
end
