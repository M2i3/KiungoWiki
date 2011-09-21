class Recording 
  include Mongoid::Document
  include Mongoid::Timestamps
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  after_initialize :set_defaults

  field :title, :type => String
  field :recording_date, :type => IncDate
  field :recording_location, :type => String
  field :duration, :type => String
  field :rythm, :type => Integer
  field :sample_rate, :type => Integer
  field :work_id, :type => Integer
  
#  validates_length_of :work_title, :in=>1..500, :allow_nil=>true
#  validates_numericality_of :duration, :greater_than=>0, :allow_nil=>true  
  validates_numericality_of :rythm, :greater_than=>0, :allow_nil=>true
  validates_numericality_of :sample_rate, :greater_than=>0, :allow_nil=>true

  embeds_one :work_wiki_link, :as => :linkable
  accepts_nested_attributes_for :work_wiki_link



  def work_title
    self.work_wiki_link.title 
  end
  def work_title=(value)
    self.work_wiki_link.title = value
  end

  def title
    self.work_title
  end

  def artists
    []
  end
  
  def albums
    []
  end

  private 
  def set_defaults
    self.work_wiki_link = WorkWikiLink.new unless self.work_wiki_link
  end
end
