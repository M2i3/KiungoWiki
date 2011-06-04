class Recording
  include Mongoid::Document
  field :recording_date, :type => DateTime
  field :recording_location, :type => String
  field :duration, :type => Integer
  field :rythm, :type => Integer
  field :sample_rate, :type => Integer
  
  validates_presence_of :duration
  validates_numericality_of :duration, :greater_than=>0
  
  validates_numericality_of :rythm, :greater_than=>0, :allow_nil=>true
  validates_numericality_of :sample_rate, :greater_than=>0, :allow_nil=>true

end
