class Recording 
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :recording_date, :type => IncDate
  field :recording_location, :type => String
  field :duration, :type => Integer
  field :rythm, :type => Integer
  field :sample_rate, :type => Integer
  field :updated_by, :default => "anonymous"
  
  validates_length_of :work_title, :in=>1..500, :allow_nil=>true
  validates_numericality_of :duration, :greater_than=>0, :allow_nil=>true  
  validates_numericality_of :rythm, :greater_than=>0, :allow_nil=>true
  validates_numericality_of :sample_rate, :greater_than=>0, :allow_nil=>true

  embeds_one :work_wiki_link

#TODO: Need to make work title work with the dirty and trigger the versionning
  def work_title
    self.work_wiki_link.title if self.work_wiki_link  
  end
  def work_title=(value)
    self.work_wiki_link = WorkWikiLink.new
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
end
