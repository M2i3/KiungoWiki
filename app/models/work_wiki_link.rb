class WorkWikiLink
  include Mongoid::Document

  field :title
  field :referenced_version, :type => Integer
  referenced_in :work
  embedded_in :linkable, :polymorphic => true

  def work=(value)
    if value
      self.work_id = value.id
      self.title = value.title
      self.referenced_version = value.version
    end
  end

  def combined
    self.title.to_s + ":" + self.work_id.to_s
  end

  def encoded_link
    if self.work_id 
      work_id.to_s.to_query("b")
    else
      Base64::encode64(self.title).to_query("u")
    end
  end

  def combined_link
    {id: self.encoded_link, name: self.title}
  end 
end
