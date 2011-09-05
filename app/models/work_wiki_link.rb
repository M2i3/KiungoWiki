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
      Base64::encode64(self.title.to_s).to_query("u")
    end
  end
  
  def encoded_link=(value)
    puts "we are called with value:" + (value || "")
    case value[0..1]
      when "u="
        self.title = Base64::decode64(value.from(2))
      when "b="
        self.work = Work.find(value.from(2))
      else
        self.title = value
    end
  end

  def combined_link
    if self.title || self.work_id 
      {id: self.encoded_link, name: self.title.to_s}
    end
  end 
end
