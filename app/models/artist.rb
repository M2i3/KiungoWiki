class Artist 
  include Mongoid::Document
  include Mongoid::Timestamps
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :name, :type => String
  field :birth_date, :type => IncDate
  field :birth_location, :type => String
  field :death_date, :type => IncDate
  field :death_location, :type => String

  validates_presence_of :name

  def works
    []
  end
  
  def albums
    []
  end

  private 
  def set_defaults
  end
end
