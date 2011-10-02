class RawCategory
  include Mongoid::Document

  set_database :raw_db
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :category_id, :type => String
  field :category_name, :type => String

  private 
  def set_defaults
  end
end
