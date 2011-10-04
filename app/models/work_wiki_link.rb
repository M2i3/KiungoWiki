class WorkWikiLink
  include Mongoid::Document

  field :reference
  field :title
  referenced_in :work
  embedded_in :linkable, :polymorphic => true

  def reference_text
    self.reference
  end
  
  def reference_text=(value)
    self.reference = value

    wsq = WorkSearchQuery.new(value)
    if wsq[:oid]
      self.work = Work.find(wsq[:oid]) 
      self.title = self.work.title
    else
      self.work = nil
      self.title = self.reference
    end
  end

  def combined_link
    if self.reference_text || self.title
      {id: self.reference_text, name: self.title.to_s}
    end
  end 
end
