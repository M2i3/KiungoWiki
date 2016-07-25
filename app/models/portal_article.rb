class PortalArticle
  include Mongoid::Document

  before_save :cache_title

  field :title, :type => String
  field :category, :type => String, :default=>"general"
  field :publish_date, :type => Date, :default => lambda {DateTime.now}

  field :content, :type => String, :default => ""

  embeds_one :featured_wiki_link, as: :linkable, class_name:"Link"
  index({category: 1, publish_date: 1})

  def summary(length=nil)
    if length
      self.content[0..length] + (self.content.size > length ? "..." : "")
    else
      (/(.*?)\r\n\r\n/m.match(self.content) || /(.*?)\n\n/m.match(self.content) || self.content).to_s      
    end
  end

  def more?(length=nil)
    if length
      self.content.size > length
    else
      self.summary != self.content
    end
  end

  def featured_wiki_link_text
    (featured_wiki_link && featured_wiki_link.reference_text) || ""
  end

  def featured_wiki_link_combined_links
    [featured_wiki_link && featured_wiki_link.combined_link]
  end

  def featured_wiki_link_text=(value)
    self.featured_wiki_link = featured_wiki_link_klass.new({:reference_text=>value})
  end

  def to_param
    self.title.parameterize + ":" + self.id.to_s
  end

  class << self
    def id_from_param(param)
      param.split(":").last
    end
  end

  protected
  def featured_wiki_link_klass
    "#{self.category}_wiki_link".classify.constantize
  end

  def cache_title
    self[:title] = self.title if generated_title?
  end

end
