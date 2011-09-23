class WorkWikiLink
  include Mongoid::Document

  field :reference
  field :title
  referenced_in :work
  embedded_in :linkable, :polymorphic => true

  def work=(value)
    if value
      self.work_id = value.id
      self.title = value.title
    else   
      self.title = nil
      self.work_id = nil
    end
  end

  def encoded_link
    self.title
  end
  
  def encoded_link=(value)
    self.reference = value
    wsq = WorkSearchQuery.new(value)
    if wsq[:oid]
      self.work = Work.find(wsq[:oid]) 
    else
      self.work = nil
      self.title = self.reference
    end
  end

  def combined_link
    if self.title || self.work_id 
      {id: self.encoded_link, name: self.title.to_s}
    end
  end 
end
