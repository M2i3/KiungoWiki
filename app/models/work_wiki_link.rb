class WorkWikiLink
  include Mongoid::Document

  field :title
  field :referenced_version, :type => Integer
  referenced_in :work

#  embedded_in :parent_link, :inverse_of => :work_wiki_link

  def work=(value)
    if value
      self.title = value.title
      self.referenced_version = value.version
    end
  end

  def combined
    self.title.to_s + ":" + self.work_id.to_s
  end
end
