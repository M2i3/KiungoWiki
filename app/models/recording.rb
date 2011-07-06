class Recording
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :work_name, :type => String
  field :recording_date, :type => DateTime #VarPrecisionDate
  field :recording_location, :type => String
  field :duration, :type => Integer
  field :rythm, :type => Integer

  field :updated_by, :default => "anonymous"
  

  validates_numericality_of :duration, :greater_than=>0, :allow_nil=>true  
  validates_numericality_of :rythm, :greater_than=>0, :allow_nil=>true

  def title
    self.work_name
  end

end
