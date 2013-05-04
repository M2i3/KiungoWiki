class SupplementarySection
  include Mongoid::Document

  before_save :cache_title

  field :title, type: String, default: ""
  field :publish_date, type: Date, default: lambda {DateTime.now}
  field :content, type: String, default: ""

  embedded_in :artist, inverse_of: :supplementary_sections
  embedded_in :release, inverse_of: :supplementary_sections
  embedded_in :recording, inverse_of: :supplementary_sections
  embedded_in :work, inverse_of: :supplementary_sections
  index({publish_date: 1})

  def title
    self[:title]
  end

  def content
    self[:content]
  end

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

  def to_param
    self.title.parameterize + ":" + self.id.to_s
  end

  class << self
    def id_from_param(param)
      param.split(":").last
    end
  end

  protected

  def cache_title
    self[:title] = self.title
  end

end
