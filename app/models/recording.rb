class Recording
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :work_name, :type => String
  field :recording_date, :type => DateTime #VarPrecisionDate
  field :recording_location, :type => String
  field :duration, :type => Integer
  field :rythm, :type => Integer
  field :sample_rate, :type => Integer

  field :updated_by, :default => "anonymous"
  

  validates_length_of :work_name, :in=>1..500, :allow_nil=>true
  validates_numericality_of :duration, :greater_than=>0, :allow_nil=>true  
  validates_numericality_of :rythm, :greater_than=>0, :allow_nil=>true
  validates_numericality_of :sample_rate, :greater_than=>0, :allow_nil=>true

  def title
    self.work_name
  end

  def artists
    []
  end
  
  def albums
    []
  end
end
