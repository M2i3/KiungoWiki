class WorkWikiLink
  include Mongoid::Document

  field :title
  field :referenced_version, :type => Integer
  referenced_in :work

  embedded_in :parent_link, :inverse_of => :work_wiki_link

  before_save :record_cached_attributes

  private
  def record_cached_attributes
    if work
      self.title = work.title
      self.referenced_version = work.version
    end
  end
end
