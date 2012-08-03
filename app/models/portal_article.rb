class PortalArticle
  include Mongoid::Document

  field :title, :type => String
  field :category, :type => String, :default=>"general"
  field :publish_date, :type => Date, :default => lambda {DateTime.now}

  field :content, :type => String, :default => ""

  embeds_one :featured_wiki_link, as: :linkable, class_name:"Link"
  index [:category, :publish_date]

  def title
    if self.featured_wiki_link
      self.category + " du mois: " + self.featured_wiki_link.display_text
    else
      self[:title]
    end
  end

  def summary
    (/(.*?)\r\n\r\n/m.match(self.content) || /(.*?)\n\n/m.match(self.content) || self.content).to_s
  end

  def more?
    self.summary != self.content
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

  protected
  def featured_wiki_link_klass
    "#{self.category}_wiki_link".classify.constantize
  end

end
