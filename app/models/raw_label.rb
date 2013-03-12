class RawLabel 
  include Mongoid::Document
  include Mongoid::Timestamps

#  set_database :raw_db
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :label_name, :type => String
  field :label_id, :type => String

  private 
  def set_defaults
  end
end
