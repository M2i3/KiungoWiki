class RawRecordingSupportLink
  include Mongoid::Document

#  set_database :raw_db
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :recording_id, :type => String
  field :support_id, :type => String
  field :track, :type => String
  field :support_element_id, :type => String
  field :face, :type => String
  field :notes, :type => String

  private 
  def set_defaults
  end
end
